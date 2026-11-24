import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_shimmer.dart';

/// Skeleton loading card mirroring [PostCard] proportions for the main feed.
class PostCardSkeleton extends StatelessWidget {
  final bool showImage;

  const PostCardSkeleton({
    super.key,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ext.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: ext.borderLight, width: 0.8) : null,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ShamsShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  const ShamsSkeletonBone(
                    width: 46,
                    height: 46,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShamsSkeletonBone(
                          width: 136,
                          height: 14,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        SizedBox(height: 8),
                        ShamsSkeletonBone(
                          width: 92,
                          height: 10,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShamsSkeletonBone(
                    width: 34,
                    height: 34,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShamsSkeletonBone(
                    width: double.infinity,
                    height: 13,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  SizedBox(height: 8),
                  ShamsSkeletonBone(
                    width: 240,
                    height: 13,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  SizedBox(height: 8),
                  ShamsSkeletonBone(
                    width: 165,
                    height: 13,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (showImage)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 14,
                  end: 14,
                  bottom: 12,
                ),
                child: ShamsSkeletonBone(
                  width: double.infinity,
                  height: 190,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            Divider(color: ext.dividerLight, thickness: 1, height: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ShamsSkeletonBone(
                        width: 54,
                        height: 22,
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                      ),
                      SizedBox(width: 18),
                      ShamsSkeletonBone(
                        width: 54,
                        height: 22,
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                      ),
                    ],
                  ),
                  ShamsSkeletonBone(
                    width: 26,
                    height: 22,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a balanced list of post skeleton cards while the feed is loading.
class PostFeedSkeletonList extends StatelessWidget {
  const PostFeedSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PostCardSkeleton(showImage: true),
        PostCardSkeleton(showImage: false),
        PostCardSkeleton(showImage: true),
      ],
    );
  }
}

