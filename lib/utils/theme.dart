import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// Shams Platform — App Theme
///
/// Centralizes all theming decisions. Use [ShamsTheme.light] when constructing
/// [MaterialApp] to apply the brand design system globally.
class ShamsTheme {
  // Private constructor — this class should not be instantiated.
  const ShamsTheme._();

  /// The primary light theme for the Shams Platform.
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,

      // Primary
      primary: ShamsColors.primaryBlue,
      onPrimary: ShamsColors.bgWhite,
      primaryContainer: Color(0xFFD6E4FF),
      onPrimaryContainer: Color(0xFF001E6C),

      // Secondary (Solar Yellow)
      secondary: ShamsColors.solarYellow,
      onSecondary: ShamsColors.textGray,
      secondaryContainer: Color(0xFFFFF3CC),
      onSecondaryContainer: Color(0xFF3D2C00),

      // Tertiary (Verified Green)
      tertiary: ShamsColors.verifiedGreen,
      onTertiary: ShamsColors.bgWhite,
      tertiaryContainer: Color(0xFFB7F0CE),
      onTertiaryContainer: Color(0xFF003920),

      // Error
      error: Color(0xFFBA1A1A),
      onError: ShamsColors.bgWhite,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      // Surface / Background
      surface: ShamsColors.bgWhite,
      onSurface: ShamsColors.textGray,
      surfaceContainerHighest: Color(0xFFF0F4FF),
      onSurfaceVariant: Color(0xFF44474F),

      // Outline
      outline: Color(0xFF74777F),
      outlineVariant: Color(0xFFC4C7CF),

      // Scrim & Shadow
      scrim: Colors.black,
      inverseSurface: Color(0xFF2F3038),
      onInverseSurface: Color(0xFFF1F0F7),
      inversePrimary: Color(0xFFADC6FF),
    );

    final textTheme = GoogleFonts.tajawalTextTheme().copyWith(
      displayLarge: GoogleFonts.tajawal(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: ShamsColors.textGray,
      ),
      displayMedium: GoogleFonts.tajawal(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: ShamsColors.textGray,
      ),
      displaySmall: GoogleFonts.tajawal(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: ShamsColors.textGray,
      ),
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: ShamsColors.textGray,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: ShamsColors.textGray,
      ),
      headlineSmall: GoogleFonts.tajawal(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ShamsColors.textGray,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: ShamsColors.textGray,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ShamsColors.textGray,
      ),
      titleSmall: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ShamsColors.textGray,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: ShamsColors.textGray,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ShamsColors.textGray,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: ShamsColors.textGray,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ShamsColors.bgWhite,
      ),
      labelMedium: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: ShamsColors.textGray,
      ),
      labelSmall: GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: ShamsColors.textGray,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: ShamsColors.primaryBlue,
      scaffoldBackgroundColor: ShamsColors.bgWhite,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: ShamsColors.primaryBlue,
        foregroundColor: ShamsColors.bgWhite,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ShamsColors.bgWhite,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShamsColors.primaryBlue,
          foregroundColor: ShamsColors.bgWhite,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ShamsColors.primaryBlue,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: ShamsColors.primaryBlue, width: 1.5),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F7FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ShamsColors.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        hintStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: const Color(0xFF9EA3B0),
        ),
        labelStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: ShamsColors.textGray,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: ShamsColors.bgWhite,
        elevation: 2,
        shadowColor: Color(0x1A0052CC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F4FF),
        labelStyle: GoogleFonts.tajawal(
          fontSize: 13,
          color: ShamsColors.primaryBlue,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEF0F4),
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2F3038),
        contentTextStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
