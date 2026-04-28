import 'package:flutter/material.dart';

/// Shams Platform — Brand Color Palette
///
/// All color constants are defined here as the single source of truth.
/// Always reference these values instead of using raw hex codes elsewhere.
class ShamsColors {
  // Private constructor — this class should not be instantiated.
  const ShamsColors._();

  /// Primary brand blue — used for buttons, links, and key UI elements.
  static const Color primaryBlue = Color(0xFF0052CC);

  /// Solar yellow — used for highlights, badges, and accents.
  static const Color solarYellow = Color(0xFFffc53d);

  /// Verified green — used for success states and verification indicators.
  static const Color verifiedGreen = Color(0xFF27AE60);

  /// Background white — default surface and scaffold background color.
  static const Color bgWhite = Color(0xFFFFFFFF);

  /// Text gray — primary body text color.
  static const Color textGray = Color(0xFF4A4A4A);
}
