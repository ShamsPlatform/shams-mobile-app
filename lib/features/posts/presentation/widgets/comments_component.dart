import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// دالة مساعدة لعرض التعليقات كـ Modal Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showCommentsSheet(
  BuildContext context, {
  required String postId,
}) {
  return showShamsModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CommentsComponent(postId: postId),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CommentsComponent — نافذة التعليقات
//
// • Uses context.watch<FeedProvider>() instead of Consumer<FeedProvider>.
// • All mutations use context.read<FeedProvider>() inside callbacks.
// ─────────────────────────────────────────────────────────────────────────────

class CommentsComponent extends StatefulWidget {
  final String postId;

  const CommentsComponent({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsComponent> createState() => _CommentsComponentState();
}

class _CommentsComponentState extends State<CommentsComponent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<FeedProvider>().addComment(widget.postId, text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final feed = context.watch<FeedProvider>();
    final post = feed.getPostById(widget.postId);

    final maxSheetHeight = math.max(0.0, screenH - bottomInset);
    final sheetHeight = math.min(screenH * 0.85, maxSheetHeight);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: ext.backgroundLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (post == null) {
              if (constraints.maxHeight < 72) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHandle(ext),
                      _buildPostNotFound(l10n, ext),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  _buildHandle(ext),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildPostNotFound(l10n, ext),
                      ),
                    ),
                  ),
                ],
              );
            }

            final currentComments = post.comments;
            if (constraints.maxHeight < 72) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHandle(ext),
                    _buildTitle(currentComments.length, l10n),
                    Divider(height: 1, thickness: 1, color: ext.borderLight),
                    if (currentComments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: _buildEmpty(l10n),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: currentComments.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          thickness: 1,
                          color: ext.dividerLight,
                          indent: 70,
                        ),
                        itemBuilder: (context, index) {
                          final comment = currentComments[index];
                          return InkWell(
                            onTap: () => _showCommentMenu(
                              context,
                              index,
                              currentComments,
                              post.author?.id,
                            ),
                            child: _CommentTile(
                              comment: comment,
                              onLikeTap: () => context
                                  .read<FeedProvider>()
                                  .toggleCommentLike(widget.postId, comment.id),
                            ),
                          );
                        },
                      ),
                    Divider(height: 1, thickness: 1, color: ext.borderLight),
                    _buildInputBar(l10n),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(child: _buildHandle(ext)),
                      ),
                      SliverToBoxAdapter(
                        child: _buildTitle(currentComments.length, l10n),
                      ),
                      SliverToBoxAdapter(
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: ext.borderLight,
                        ),
                      ),
                      if (currentComments.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: _buildEmpty(l10n),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          sliver: SliverList.separated(
                            itemCount: currentComments.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              thickness: 1,
                              color: ext.dividerLight,
                              indent: 70,
                            ),
                            itemBuilder: (context, index) {
                              final comment = currentComments[index];
                              return InkWell(
                                onTap: () => _showCommentMenu(
                                  context,
                                  index,
                                  currentComments,
                                  post.author?.id,
                                ),
                                child: _CommentTile(
                                  comment: comment,
                                  onLikeTap: () => context
                                      .read<FeedProvider>()
                                      .toggleCommentLike(
                                        widget.postId,
                                        comment.id,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: ext.borderLight),
                _buildInputBar(l10n),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostNotFound(AppLocalizations l10n, ShamsExtendedColors ext) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        l10n.postNotFound,
        textAlign: TextAlign.center,
        style: GoogleFonts.tajawal(
          fontSize: 15,
          color: ext.textHint,
        ),
      ),
    );
  }

  Widget _buildHandle(ShamsExtendedColors ext) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: ext.handleBar,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _buildTitle(int count, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Flexible(
            child: Text(
              l10n.comments,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 52,
            color: colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noCommentsYet,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: ext.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: ext.inputFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ext.borderLight),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        size: 22,
                        color: ext.textHint,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.writeCommentHint,
                        hintStyle: GoogleFonts.tajawal(
                          fontSize: 13.5,
                          color: ext.textHint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsetsDirectional.only(end: 14),
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _sendComment,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.send_rounded,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentMenu(
    BuildContext context,
    int index,
    List<Comment> currentComments,
    String? postAuthorId,
  ) {
    final comment = currentComments[index];
    final currentUser = context.read<ProfileProvider>().currentUserOrPlaceholder;
    final commentAuthorId = comment.user.id;
    final l10n = AppLocalizations.of(context)!;

    final bool canDelete = currentUser.id == commentAuthorId ||
        (postAuthorId != null && currentUser.id == postAuthorId);

    showShamsModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<ShamsExtendedColors>()!
                    .handleBar,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.copy_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              title:
                  Text(l10n.copyText, style: GoogleFonts.tajawal(fontSize: 16)),
              onTap: () async {
                Navigator.pop(context);
                await Clipboard.setData(ClipboardData(text: comment.text));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.commentCopied,
                        style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onInverseSurface),
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.inverseSurface,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            if (canDelete)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error),
                title: Text(
                  l10n.deleteComment,
                  style: GoogleFonts.tajawal(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FeedProvider>()
                      .deleteComment(widget.postId, comment.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CommentTile — تعليق واحد
// ─────────────────────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback onLikeTap;

  const _CommentTile({required this.comment, required this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    final avatarPath =
        comment.user.profileImageUrl ?? 'assets/images/logo/shams logo.png';
    final bool isNetwork = avatarPath.startsWith('http');
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة الشخصية
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: isNetwork
                  ? Image.network(
                      avatarPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _avatarFallback(colorScheme, ext),
                    )
                  : (avatarPath.startsWith('assets/')
                      ? Image.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _avatarFallback(colorScheme, ext),
                        )
                      : (File(avatarPath).existsSync()
                          ? Image.file(
                              File(avatarPath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _avatarFallback(colorScheme, ext),
                            )
                          : _avatarFallback(colorScheme, ext))),
            ),
          ),

          const SizedBox(width: 10),

          // محتوى التعليق
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المستخدم + الوقت
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            comment.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.4,
                          ),
                          child: Text(
                            l10n.formatRelativeTimeLocalized(comment.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 11.5,
                              color: ext.textHint,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 4),

                // نص التعليق
                Text(
                  comment.text,
                  style: GoogleFonts.tajawal(
                    fontSize: 13.5,
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                // زر الإعجاب
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLikeTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comment.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 15,
                        color: comment.isLiked ? colorScheme.error : ext.textHint,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          comment.likesCount > 0
                              ? '${comment.likesCount}'
                              : l10n.like,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: comment.isLiked
                                ? colorScheme.error
                                : ext.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(ColorScheme colorScheme, ShamsExtendedColors ext) {
    return Container(
      color: ext.avatarFallbackBg,
      child: Center(
        child: Text(
          comment.user.name.isNotEmpty ? comment.user.name[0].toUpperCase() : '?',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
