import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Column(
      children: [
        Text(
          workshop.name,
          style: GoogleFonts.tajawal(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          workshop.handle,
          style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              workshop.city,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.star_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              '${workshop.rating}/5',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '(${workshop.reviewCount} تقييم)',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            workshop.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.secondary,
                      foregroundColor: isFollowing
                          ? Theme.of(context)
                              .extension<ShamsExtendedColors>()!
                              .textHint
                          : Theme.of(context).colorScheme.onSecondary,
                      elevation: 0,
                      side: isFollowing
                          ? BorderSide(
                              color: Theme.of(context)
                                  .extension<ShamsExtendedColors>()!
                                  .borderLight,
                              width: 1.5,
                            )
                          : BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isFollowing ? 'الغاء المتابعة' : 'متابعة',
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const _CircularSocialIcon(
                icon: Icons.camera_alt_rounded,
                color: Color(0xFFE1306C),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.grey.shade300, thickness: 1),
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
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ميزة التواصل متوفرة قريباً',
              style: GoogleFonts.tajawal(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
