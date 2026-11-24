import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';

/// Public workshop profile identity, rating, bio, follow action, and social buttons.
class WorkshopProfileInfo extends StatelessWidget {
  const WorkshopProfileInfo({
    super.key,
    required this.workshop,
    required this.isFollowing,
    required this.onToggleFollow,
  });

  final Workshop workshop;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final trimmedHandle = workshop.handle.trim();
    final formattedHandle = trimmedHandle.isEmpty
        ? ''
        : (trimmedHandle.startsWith('@') ? trimmedHandle : '@$trimmedHandle');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Text(
            workshop.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (formattedHandle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            formattedHandle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      l10n.localizeCity(workshop.city),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    workshop.reviewCount > 0 || workshop.rating > 0
                        ? '${workshop.rating.toStringAsFixed(1)}/5'
                        : l10n.newLabel,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                l10n.reviewsCountLabel(workshop.reviewCount),
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: ext.textHint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          child: Text(
            workshop.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 13.5,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onToggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? colorScheme.surface
                          : colorScheme.secondary,
                      foregroundColor: isFollowing
                          ? ext.textHint
                          : colorScheme.onSecondary,
                      elevation: 0,
                      side: isFollowing
                          ? BorderSide(
                              color: ext.borderLight,
                              width: 1.5,
                            )
                          : BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isFollowing ? l10n.unfollow : l10n.follow,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const _CircularSocialIcon(
                icon: Icons.chat_bubble_outline_rounded,
                color: Color(0xFF25D366),
              ),
              _CircularSocialIcon(
                icon: Icons.phone_in_talk_rounded,
                color: colorScheme.onSurface,
              ),
              const _CircularSocialIcon(
                icon: Icons.camera_alt_rounded,
                color: Color(0xFFE1306C),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: ext.dividerLight, thickness: 1),
      ],
    );
  }
}

class _CircularSocialIcon extends StatelessWidget {
  const _CircularSocialIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.contactSoon,
              style: GoogleFonts.tajawal(color: colorScheme.onInverseSurface),
            ),
            backgroundColor: colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: ext.borderLight),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
