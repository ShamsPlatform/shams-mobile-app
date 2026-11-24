import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/features/posts/presentation/widgets/comments_component.dart';
import 'package:shams_mobile_app/features/posts/presentation/widgets/post_card.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/presentation/constants/workshop_assets.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshop_profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PostDetailScreen — شاشة تفاصيل المنشور
//
// • Accepts ONLY a [postId] — no full Post object is passed.
// • Reads live data from FeedProvider via context.watch() in build().
// • Mutations use context.read() strictly inside callbacks (never in build).
// • No Consumer widget is used anywhere.
// ─────────────────────────────────────────────────────────────────────────────

class PostDetailScreen extends StatelessWidget {
  /// The unique identifier of the post to display.
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // ── Single source of truth: watch the provider for live updates ──────────
    // context.watch causes the entire build to re-run whenever FeedProvider
    // calls notifyListeners(), guaranteeing the UI is always up-to-date.
    final feed = context.watch<FeedProvider>();
    final post = feed.getPostById(postId);
    final l10n = AppLocalizations.of(context)!;

    // Guard: if the post was deleted while open, pop back gracefully.
    if (post == null) {
      return Scaffold(
        backgroundColor:
            Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        appBar: _buildAppBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.postNotFound,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color:
                    Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
              ),
            ),
          ),
        ),
      );
    }

    // Resolve workshop for the post's owner display
    final workshops = context.watch<WorkshopsProvider>().workshops;
    Workshop? postWorkshop;
    if (post.workshopId != null) {
      for (final w in workshops) {
        if (w.id == post.workshopId) {
          postWorkshop = w;
          break;
        }
      }
    }
    if (postWorkshop == null && post.author != null) {
      for (final w in workshops) {
        if (w.id == post.author!.id) {
          postWorkshop = w;
          break;
        }
      }
    }

    // Derived display values — computed inside build, never stored in state.
    final username = postWorkshop?.name ?? post.author?.name ?? l10n.unknownUser;
    final userHandle = postWorkshop?.handle ?? (post.author?.email != null ? '@${post.author!.email.split('@').first}' : '@unknown');
    final avatarPath = postWorkshop?.logoUrl ?? post.author?.profileImageUrl ?? kDefaultWorkshopLogoAsset;

    return Scaffold(
      backgroundColor:
          Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,

      // ── AppBar ───────────────────────────────────────────────────────────
      appBar: _buildAppBar(context),

      // ── Body ─────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── بطاقة المنشور الكاملة ──────────────────────────────────────
            PostCard(
              username: username,
              userHandle: userHandle,
              avatarPath: avatarPath,
              content: post.textDetails,
              imagePaths: post.images.isNotEmpty ? post.images : null,
              timeAgoText: l10n.formatRelativeTimeLocalized(post.createdAt),
              heroTag: 'post-media-${post.id}',
              likesCount: post.likesCount,
              commentsCount: post.comments.length,
              sharesCount: 0,
              isLiked: post.isLiked,
              // Show full text — no truncation on the detail screen.
              maxLines: 999,
              // context.read() inside a callback — correct usage.
              onLikeToggle: (_) =>
                  context.read<FeedProvider>().toggleLike(postId),
              onCommentTap: () => _openCommentsSheet(context),
              onShareTap: () => _onShare(context),
              onMenuTap: () => _showMenu(context),
              onUserTap: () {
                final workshops = context.read<WorkshopsProvider>().workshops;
                Workshop? targetWorkshop;

                if (post.workshopId != null) {
                  for (final w in workshops) {
                    if (w.id == post.workshopId) {
                      targetWorkshop = w;
                      break;
                    }
                  }
                }

                if (targetWorkshop == null && post.author != null) {
                  for (final w in workshops) {
                    if (w.id == post.author!.id) {
                      targetWorkshop = w;
                      break;
                    }
                  }
                }
                
                final targetId = targetWorkshop?.id ?? post.author?.id;
                if (targetId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkshopProfile(workshopId: targetId),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 8),

            // ── قسم التعليقات ─────────────────────────────────────────────
            _CommentsSection(postId: postId),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _openCommentsSheet(BuildContext context) async {
    await showCommentsSheet(context, postId: postId);
    // No setState needed — FeedProvider notified, context.watch rebuilds us.
  }

  void _onShare(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.postShared,
          style: GoogleFonts.tajawal(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showShamsModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).extension<ShamsExtendedColors>()!.handleBar,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            _MenuOption(
              icon: Icons.bookmark_border_rounded,
              label: l10n.savePost,
              onTap: () => Navigator.pop(context),
            ),
            _MenuOption(
              icon: Icons.person_add_outlined,
              label: l10n.followAccount,
              onTap: () => Navigator.pop(context),
            ),
            _MenuOption(
              icon: Icons.flag_outlined,
              label: l10n.reportPost,
              color: Theme.of(context).colorScheme.error,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>();
    final dividerColor = ext?.dividerLight ?? colorScheme.outlineVariant;

    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0.5,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colorScheme.onSurface,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l10n.postDetails,
        style: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            size: 22,
            color: colorScheme.onSurface,
          ),
          onPressed: () => _onShare(context),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Divider(
          height: 1.0,
          thickness: 1.0,
          color: dividerColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CommentsSection — the full comments block (header + preview + add button).
//
// Reads the live comments list from context.watch inside its own build so
// it re-renders automatically when FeedProvider notifies (e.g. after addComment).
// ─────────────────────────────────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  final String postId;

  const _CommentsSection({required this.postId});

  @override
  Widget build(BuildContext context) {
    // Watch FeedProvider directly to make this section perfectly reactive
    final feed = context.watch<FeedProvider>();
    final post = feed.getPostById(postId);
    final l10n = AppLocalizations.of(context)!;

    if (post == null) return const SizedBox.shrink();
    final comments = post.comments;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس القسم ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n.comments,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Live count badge — updates automatically via context.watch
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '${comments.length}',
                              style: GoogleFonts.tajawal(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.4,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _openSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            l10n.viewAll,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(
            height: 1,
            thickness: 1,
          ),

          // ── معاينة أول تعليقين ─────────────────────────────────────────────
          if (comments.isNotEmpty)
            ...comments.take(2).expand((comment) {
              return [
                _PreviewComment(
                  avatarPath:
                      comment.user.profileImageUrl ??
                      'assets/images/logo/shams logo.png',
                  userName: comment.user.name,
                  text: comment.text,
                  timeAgo: l10n.formatRelativeTimeLocalized(comment.createdAt),
                ),
                if (comment != comments.take(2).last)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 62,
                  ),
              ];
            }),

          // ── زر إضافة تعليق ─────────────────────────────────────────────────
          GestureDetector(
            // context.read() inside a callback — correct usage.
            onTap: () => _openSheet(context),
            child: Container(
              margin: const EdgeInsets.all(14),
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).extension<ShamsExtendedColors>()!.inputFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.writeCommentHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        color: Theme.of(context)
                            .extension<ShamsExtendedColors>()!
                            .textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    await showCommentsSheet(context, postId: postId);
    // No setState — FeedProvider notifies, context.watch in the parent rebuilds.
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PreviewComment — مصغّر تعليق في القائمة
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewComment extends StatelessWidget {
  final String avatarPath;
  final String userName;
  final String text;
  final String timeAgo;

  const _PreviewComment({
    required this.avatarPath,
    required this.userName,
    required this.text,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = avatarPath.startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة الشخصية
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.15),
              ),
            ),
            child: ClipOval(
              child: isNetwork
                  ? Image.network(avatarPath, fit: BoxFit.cover)
                  : (avatarPath.startsWith('assets/')
                      ? Image.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Theme.of(context)
                                .extension<ShamsExtendedColors>()!
                                .avatarFallbackBg,
                            child: Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.tajawal(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        )
                      : (File(avatarPath).existsSync()
                          ? Image.file(
                              File(avatarPath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Theme.of(context)
                                    .extension<ShamsExtendedColors>()!
                                    .avatarFallbackBg,
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.tajawal(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Theme.of(context)
                                  .extension<ShamsExtendedColors>()!
                                  .avatarFallbackBg,
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.4,
                          ),
                          child: Text(
                            timeAgo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .extension<ShamsExtendedColors>()!
                                  .textHint,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuOption — خيار في قائمة خيارات المنشور
// ─────────────────────────────────────────────────────────────────────────────

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: effectiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
