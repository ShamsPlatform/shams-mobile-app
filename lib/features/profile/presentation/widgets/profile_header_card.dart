import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';

/// Top profile card displaying avatar, edit button, display name, handle,
/// optional phone number, and bio/location indicator.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.currentUser,
    required this.onEditProfileTap,
  });

  final AppUser currentUser;
  final VoidCallback onEditProfileTap;

  ImageProvider _resolveProfileImage(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/logo/shams logo.png');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/images/logo/shams logo.png');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final topInset = MediaQuery.paddingOf(context).top;
    final phone = currentUser.phone?.trim() ?? '';
    final bio = currentUser.bio?.trim() ?? '';
    final location = currentUser.location?.trim() ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ext.backgroundLight,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(25, topInset + 20, 25, 36),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 4),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.surface,
                  backgroundImage: _resolveProfileImage(
                    currentUser.profileImageUrl,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 8),
                child: Material(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onEditProfileTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.editProfile,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        currentUser.name == 'جاري التحميل...'
                            ? l10n.loadingLabel
                            : currentUser.name,
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '@${currentUser.email.split('@').first}',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        textDirection: TextDirection.ltr,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 2),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bio,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.localizeCity(location),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
