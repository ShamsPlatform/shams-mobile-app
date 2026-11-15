import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';

/// Visual styling descriptor for each [NotificationType].
class _NotificationVisual {
  const _NotificationVisual(this.icon, this.color);

  final IconData icon;
  final Color color;
}

const Map<NotificationType, _NotificationVisual> _typeVisuals = {
  NotificationType.like:
      _NotificationVisual(Icons.favorite_rounded, Color(0xFFD32F2F)),
  NotificationType.comment:
      _NotificationVisual(Icons.comment_rounded, Color(0xFF2CC069)),
  NotificationType.reply:
      _NotificationVisual(Icons.reply_rounded, Color(0xFF0056C6)),
  NotificationType.workshopUpdate:
      _NotificationVisual(Icons.local_offer_rounded, Color(0xFF2CC069)),
  NotificationType.maintenanceStatus:
      _NotificationVisual(Icons.build_circle_rounded, Color(0xFFFFD600)),
  NotificationType.message:
      _NotificationVisual(Icons.chat_bubble_outline_rounded, Color(0xFF0056C6)),
  NotificationType.system:
      _NotificationVisual(Icons.notifications_rounded, Color(0xFF9EA3B0)),
};

/// Single notification row card displayed inside [NotificationsScreen].
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notif,
    required this.onTap,
  });

  final AppNotification notif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.isRead;
    final visual = _typeVisuals[notif.type]!;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread
            ? colorScheme.primary.withValues(alpha: 0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            else
              const SizedBox(width: 15),
            CircleAvatar(
              backgroundColor: visual.color.withValues(alpha: 0.12),
              radius: 22,
              child: Icon(
                visual.icon,
                color: visual.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.message,
                    style: GoogleFonts.tajawal(
                      fontSize: 12.5,
                      color: ext.textHint,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notif.createdAt),
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: ext.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
