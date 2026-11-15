-- Phase 9 Backlog SQL Migration (K2, N1, N2)
-- Run in the Supabase Dashboard SQL Editor.
-- All statements are idempotent and safe to re-run.
--
-- IMPORTANT AFTER APPLYING OPTION 2 NOTIFICATION TRIGGERS:
-- Build and ship the Flutter client with:
--   --dart-define=USE_DB_NOTIFICATION_TRIGGERS=true
-- (or flip Env.useDbNotificationTriggers defaultValue to true)
-- so client-side notification inserts are disabled and triggers do not duplicate rows.

-- ---------------------------------------------------------------------------
-- 1. K2: Atomic post view counter RPC
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.increment_post_views(post_ids uuid[])
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF post_ids IS NULL OR COALESCE(array_length(post_ids, 1), 0) = 0 THEN
    RETURN;
  END IF;

  UPDATE public.posts
  SET views_count = COALESCE(views_count, 0) + 1
  WHERE id = ANY(post_ids);
END;
$$;

REVOKE ALL ON FUNCTION public.increment_post_views(uuid[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.increment_post_views(uuid[]) TO authenticated;

-- ---------------------------------------------------------------------------
-- 2. N2: Keep workshops.rating & workshops.review_count synced from reviews
-- ---------------------------------------------------------------------------
ALTER TABLE public.workshops
  ADD COLUMN IF NOT EXISTS rating numeric(3, 2) NOT NULL DEFAULT 0.0;

ALTER TABLE public.workshops
  ADD COLUMN IF NOT EXISTS review_count integer NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public.sync_workshop_rating_from_reviews()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  target_workshop_id uuid;
BEGIN
  IF TG_OP = 'DELETE' THEN
    target_workshop_id := OLD.workshop_id;
  ELSE
    target_workshop_id := NEW.workshop_id;
  END IF;

  IF target_workshop_id IS NOT NULL THEN
    UPDATE public.workshops w
    SET
      rating = COALESCE(
        (SELECT ROUND(AVG(r.rating)::numeric, 1)
         FROM public.reviews r
         WHERE r.workshop_id = target_workshop_id),
        0.0
      ),
      review_count = (
        SELECT COUNT(*)::integer
        FROM public.reviews r
        WHERE r.workshop_id = target_workshop_id
      )
    WHERE w.id = target_workshop_id;
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.workshop_id IS DISTINCT FROM NEW.workshop_id THEN
    UPDATE public.workshops w
    SET
      rating = COALESCE(
        (SELECT ROUND(AVG(r.rating)::numeric, 1)
         FROM public.reviews r
         WHERE r.workshop_id = OLD.workshop_id),
        0.0
      ),
      review_count = (
        SELECT COUNT(*)::integer
        FROM public.reviews r
        WHERE r.workshop_id = OLD.workshop_id
      )
    WHERE w.id = OLD.workshop_id;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_workshop_rating_from_reviews ON public.reviews;
CREATE TRIGGER trg_sync_workshop_rating_from_reviews
AFTER INSERT OR UPDATE OR DELETE ON public.reviews
FOR EACH ROW
EXECUTE FUNCTION public.sync_workshop_rating_from_reviews();

-- Backfill existing workshop ratings from live reviews rows.
UPDATE public.workshops w
SET
  rating = COALESCE(agg.avg_rating, 0.0),
  review_count = COALESCE(agg.cnt, 0)
FROM (
  SELECT
    workshop_id,
    ROUND(AVG(rating)::numeric, 1) AS avg_rating,
    COUNT(*)::integer AS cnt
  FROM public.reviews
  GROUP BY workshop_id
) agg
WHERE w.id = agg.workshop_id;

UPDATE public.workshops w
SET rating = 0.0, review_count = 0
WHERE NOT EXISTS (
  SELECT 1 FROM public.reviews r WHERE r.workshop_id = w.id
)
AND (w.rating <> 0.0 OR w.review_count <> 0);

-- ---------------------------------------------------------------------------
-- 3. N1 (Option 2): Server-side notification triggers
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_post_like_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  post_author_id uuid;
  post_preview text;
  liker_name text;
BEGIN
  SELECT author_id,
         CASE
           WHEN char_length(COALESCE(text_details, '')) > 30
             THEN left(text_details, 30) || '...'
           ELSE COALESCE(text_details, '')
         END
  INTO post_author_id, post_preview
  FROM public.posts
  WHERE id = NEW.post_id;

  IF post_author_id IS NULL OR post_author_id = NEW.user_id THEN
    RETURN NEW;
  END IF;

  SELECT COALESCE(NULLIF(trim(name), ''), 'مستخدم')
  INTO liker_name
  FROM public.profiles
  WHERE id = NEW.user_id;

  INSERT INTO public.notifications (user_id, title, message, type, target_id)
  VALUES (
    post_author_id,
    'إعجاب جديد',
    format('قام %s بالإعجاب بمنشورك: "%s"', COALESCE(liker_name, 'مستخدم'), post_preview),
    'like',
    NEW.post_id
  );

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_message_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  sender_name text;
BEGIN
  SELECT COALESCE(NULLIF(trim(name), ''), 'مستخدم')
  INTO sender_name
  FROM public.profiles
  WHERE id = NEW.sender_id;

  INSERT INTO public.notifications (user_id, title, message, type, target_id)
  SELECT
    cp.user_id,
    'رسالة جديدة',
    format('أرسل %s: %s', COALESCE(sender_name, 'مستخدم'), COALESCE(NEW.text, '')),
    'message',
    NEW.chat_id
  FROM public.chat_participants cp
  WHERE cp.chat_id = NEW.chat_id
    AND cp.user_id <> NEW.sender_id;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_maintenance_request_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  workshop_owner_id uuid;
  client_name text;
BEGIN
  SELECT owner_id
  INTO workshop_owner_id
  FROM public.workshops
  WHERE id = NEW.workshop_id;

  IF workshop_owner_id IS NULL OR workshop_owner_id = NEW.client_id THEN
    RETURN NEW;
  END IF;

  SELECT COALESCE(NULLIF(trim(name), ''), 'عميل')
  INTO client_name
  FROM public.profiles
  WHERE id = NEW.client_id;

  INSERT INTO public.notifications (user_id, title, message, type, target_id)
  VALUES (
    workshop_owner_id,
    'طلب صيانة جديد',
    format(
      'تلقيت طلب صيانة جديد من %s (%s)',
      COALESCE(client_name, 'عميل'),
      COALESCE(NEW.service_type, '')
    ),
    'maintenance_status',
    NEW.id
  );

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_maintenance_status_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  workshop_name text;
  status_str text;
BEGIN
  IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  SELECT COALESCE(NULLIF(trim(name), ''), 'الورشة')
  INTO workshop_name
  FROM public.workshops
  WHERE id = NEW.workshop_id;

  status_str := CASE NEW.status
    WHEN 'accepted' THEN 'مقبول'
    WHEN 'in_progress' THEN 'جارٍ التنفيذ'
    WHEN 'rejected' THEN 'مرفوض'
    WHEN 'cancelled' THEN 'ملغي'
    WHEN 'completed' THEN 'مكتمل'
    ELSE 'قيد الانتظار'
  END;

  INSERT INTO public.notifications (user_id, title, message, type, target_id)
  VALUES (
    NEW.client_id,
    'تحديث طلب الصيانة',
    format(
      'تم تحديث حالة طلب الصيانة (%s) لدى %s إلى: %s',
      COALESCE(NEW.service_type, ''),
      COALESCE(workshop_name, 'الورشة'),
      status_str
    ),
    'maintenance_status',
    NEW.id
  );

  RETURN NEW;
END;
$$;

-- Remove legacy or previously named triggers before recreating.
DROP TRIGGER IF EXISTS on_post_like_created ON public.post_likes;
DROP TRIGGER IF EXISTS on_post_like_notification ON public.post_likes;
DROP TRIGGER IF EXISTS trg_phase9_post_like_notification ON public.post_likes;
CREATE TRIGGER trg_phase9_post_like_notification
AFTER INSERT ON public.post_likes
FOR EACH ROW
EXECUTE FUNCTION public.handle_post_like_notification();

DROP TRIGGER IF EXISTS on_message_created ON public.messages;
DROP TRIGGER IF EXISTS on_message_notification ON public.messages;
DROP TRIGGER IF EXISTS trg_phase9_message_notification ON public.messages;
CREATE TRIGGER trg_phase9_message_notification
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.handle_message_notification();

DROP TRIGGER IF EXISTS on_maintenance_request_created ON public.maintenance_requests;
DROP TRIGGER IF EXISTS on_maintenance_request_notification ON public.maintenance_requests;
DROP TRIGGER IF EXISTS trg_phase9_maintenance_request_notification ON public.maintenance_requests;
CREATE TRIGGER trg_phase9_maintenance_request_notification
AFTER INSERT ON public.maintenance_requests
FOR EACH ROW
EXECUTE FUNCTION public.handle_maintenance_request_notification();

DROP TRIGGER IF EXISTS on_maintenance_status_updated ON public.maintenance_requests;
DROP TRIGGER IF EXISTS on_maintenance_status_notification ON public.maintenance_requests;
DROP TRIGGER IF EXISTS trg_phase9_maintenance_status_notification ON public.maintenance_requests;
CREATE TRIGGER trg_phase9_maintenance_status_notification
AFTER UPDATE OF status ON public.maintenance_requests
FOR EACH ROW
EXECUTE FUNCTION public.handle_maintenance_status_notification();
