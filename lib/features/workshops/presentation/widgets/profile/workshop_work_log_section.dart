import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_image_views.dart';

/// Public workshop work log section listing published project posts.
class WorkshopWorkLogSection extends StatelessWidget {
  const WorkshopWorkLogSection({super.key, required this.posts});

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.workLogTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.fullWorkLogSoon,
                        style: GoogleFonts.tajawal(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  l10n.viewAll,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (posts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.noWorkLogYet,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Theme.of(context)
                      .extension<ShamsExtendedColors>()!
                      .textHint,
                ),
              ),
            ),
          )
        else
          ...posts.map(
            (post) => _WorkLogCard(
              time: l10n.formatRelativeTimeLocalized(post.createdAt),
              content: post.textDetails,
              images: post.images,
            ),
          ),
      ],
    );
  }
}

class _WorkLogCard extends StatelessWidget {
  const _WorkLogCard({
    required this.time,
    required this.content,
    required this.images,
  });

  final String time;
  final String content;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<ShamsExtendedColors>()!
                    .backgroundLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            textAlign: TextAlign.start,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (images.isNotEmpty)
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: WorkshopCoverImage(path: images[index]),
                        ),
                        if (images.length > 1)
                          PositionedDirectional(
                            bottom: 10,
                            end: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${index + 1}/${images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
