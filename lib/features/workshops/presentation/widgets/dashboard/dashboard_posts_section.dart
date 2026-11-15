import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/utils/formatters.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/managed_post_card.dart';

/// Published posts list section on the workshop dashboard.
class DashboardPostsSection extends StatelessWidget {
  const DashboardPostsSection({
    super.key,
    required this.posts,
    required this.onEditPost,
    required this.onDeletePost,
  });

  final List<Post> posts;
  final ValueChanged<Post> onEditPost;
  final ValueChanged<Post> onDeletePost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجل الأعمال المنشور',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد أعمال منشورة حالياً.\nاضغط "نشر عمل جديد" للبدء!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: Theme.of(context)
                            .extension<ShamsExtendedColors>()!
                            .textHint,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ManagedPostCard(
                  content: post.textDetails,
                  timeAgo: formatRelativeTime(post.createdAt),
                  viewsCount: formatCompactNumber(post.viewsCount),
                  likesCount: post.likesCount,
                  imagePaths: post.images,
                  onEdit: () => onEditPost(post),
                  onDelete: () => onDeletePost(post),
                );
              },
            ),
        ],
      ),
    );
  }
}
