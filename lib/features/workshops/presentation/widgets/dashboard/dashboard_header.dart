import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';

/// Workshop dashboard header displaying editable cover and logo images.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.coverUrl,
    required this.logoUrl,
    required this.pendingCoverPath,
    required this.pendingLogoPath,
    required this.onCoverTap,
    required this.onLogoTap,
  });

  final String? coverUrl;
  final String? logoUrl;
  final String? pendingCoverPath;
  final String? pendingLogoPath;
  final VoidCallback onCoverTap;
  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    final hasCoverUrl = coverUrl != null && coverUrl!.isNotEmpty;
    final hasLogoUrl = logoUrl != null && logoUrl!.isNotEmpty;

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onTap: onCoverTap,
            child: Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: pendingCoverPath != null
                      ? Image(
                          image: FileImage(File(pendingCoverPath!)),
                          fit: BoxFit.cover,
                        )
                      : hasCoverUrl
                          ? Image.network(
                              coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _buildCoverPlaceholder(context),
                            )
                          : _buildCoverPlaceholder(context),
                ),
                const PositionedDirectional(
                  top: 16,
                  start: 16,
                  child: _CameraBadge(),
                ),
              ],
            ),
          ),
          Positioned(
            top: 100,
            child: GestureDetector(
              onTap: onLogoTap,
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: pendingLogoPath != null
                        ? ClipOval(
                            child: Image(
                              image: FileImage(File(pendingLogoPath!)),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          )
                        : hasLogoUrl
                            ? ClipOval(
                                child: Image.network(
                                  logoUrl!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _buildLogoFallback(context),
                                ),
                              )
                            : _buildLogoFallback(context),
                  ),
                  const _CameraBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      child: const Icon(
        Icons.image_outlined,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildLogoFallback(BuildContext context) {
    return CircleAvatar(
      radius: 45,
      backgroundColor:
          Theme.of(context).extension<ShamsExtendedColors>()!.avatarFallbackBg,
      child: const Icon(
        Icons.store_rounded,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}

class _CameraBadge extends StatelessWidget {
  const _CameraBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(
        Icons.camera_alt_rounded,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
