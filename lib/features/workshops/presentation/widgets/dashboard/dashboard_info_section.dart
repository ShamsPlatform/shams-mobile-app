import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/core/widgets/scrollable_image_picker.dart';

/// Workshop summary info, gallery picker, edit CTA, and followers/posts stats bar.
class DashboardInfoSection extends StatelessWidget {
  const DashboardInfoSection({
    super.key,
    required this.name,
    required this.username,
    required this.city,
    required this.galleryUrls,
    required this.pendingGalleryPaths,
    required this.followersCount,
    required this.postCount,
    required this.onAddGalleryTap,
    required this.onRemoveGalleryTap,
    required this.onEditTap,
  });

  final String name;
  final String username;
  final String city;
  final List<String> galleryUrls;
  final List<String> pendingGalleryPaths;
  final int followersCount;
  final int postCount;
  final VoidCallback onAddGalleryTap;
  final ValueChanged<int> onRemoveGalleryTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final handle = username.isNotEmpty ? '@$username' : '@workshop';
    final totalGallery = galleryUrls.length + pendingGalleryPaths.length;

    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          handle,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.localizeCity(city),
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── صور الورشة الإضافية ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                l10n.workshopImages,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($totalGallery)',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: Theme.of(context)
                      .extension<ShamsExtendedColors>()!
                      .textHint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ScrollableImagePicker(
            images: [
              ...galleryUrls,
              ...pendingGalleryPaths.map(File.new),
            ],
            onAddTap: onAddGalleryTap,
            onRemoveTap: onRemoveGalleryTap,
          ),
        ),
        const SizedBox(height: 24),

        // ── زر تعديل ملف الورشة ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 45,
            child: CustomSolidButton(
              title: l10n.editWorkshopProfile,
              onPressed: onEditTap,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── شريط الإحصائيات ──
        Divider(color: Colors.grey.shade200, height: 1),
        IntrinsicHeight(
          child: Row(
            children: [
              _StatColumn(
                count: followersCount.toString(),
                label: l10n.followers,
                icon: Icons.people_alt_outlined,
              ),
              VerticalDivider(
                color: Colors.grey.shade200,
                width: 1,
                thickness: 1,
              ),
              _StatColumn(
                count: '$postCount',
                label: l10n.postsCountLabel,
                icon: Icons.article_outlined,
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.count,
    required this.label,
    required this.icon,
  });

  final String count;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: Theme.of(context)
                    .extension<ShamsExtendedColors>()!
                    .textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
