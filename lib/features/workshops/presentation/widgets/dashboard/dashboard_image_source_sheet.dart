import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';

/// Opens the gallery/camera bottom sheet for workshop dashboard image uploads.
void showDashboardImageSourceSheet({
  required BuildContext context,
  required ImagePicker picker,
  required void Function(File file) onPicked,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(
                  ctx,
                ).extension<ShamsExtendedColors>()!.handleBar,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: l10n.chooseFromGallery,
              color: Theme.of(ctx).colorScheme.primary,
              onTap: () async {
                Navigator.pop(ctx);
                final xf = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (xf != null) onPicked(File(xf.path));
              },
            ),
            _SheetOption(
              icon: Icons.camera_alt_outlined,
              label: l10n.takePhoto,
              color: Theme.of(ctx).colorScheme.secondary,
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final xf = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (xf != null) onPicked(File(xf.path));
                } catch (_) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.cameraUnavailable,
                        style: GoogleFonts.tajawal(),
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: GoogleFonts.tajawal(fontSize: 15)),
    );
  }
}
