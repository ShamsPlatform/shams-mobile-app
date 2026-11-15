import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/presentation/constants/workshop_assets.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_image_views.dart';

/// Public workshop profile hero header with cover banner and overlapping logo avatar.
class WorkshopProfileHeader extends StatelessWidget {
  const WorkshopProfileHeader({super.key, required this.workshop});

  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          color:
              Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
          child: WorkshopCoverImage(
            path: workshop.coverUrl ?? kDefaultWorkshopCoverAsset,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -45,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .extension<ShamsExtendedColors>()!
                      .borderLight,
                ),
                clipBehavior: Clip.antiAlias,
                child: WorkshopAvatarImage(
                  path: workshop.logoUrl ?? kDefaultWorkshopLogoAsset,
                  name: workshop.name,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
