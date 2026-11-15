import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';

/// Displays a workshop cover or post image from network, asset, or local file.
class WorkshopCoverImage extends StatelessWidget {
  const WorkshopCoverImage({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return _buildPlaceholder(context);
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(context),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(context),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPlaceholder(context),
        );
      }
      return _buildPlaceholder(context);
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey),
      ),
    );
  }
}

/// Displays a workshop circular avatar from network, asset, local file, or initial fallback.
class WorkshopAvatarImage extends StatelessWidget {
  const WorkshopAvatarImage({
    super.key,
    required this.path,
    required this.name,
  });

  final String path;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return _buildFallbackAvatar(context);
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackAvatar(context),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackAvatar(context),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackAvatar(context),
        );
      }
      return _buildFallbackAvatar(context);
    }
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return Container(
      color: Theme.of(context).extension<ShamsExtendedColors>()!.avatarFallbackBg,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '؟',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
