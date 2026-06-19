import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for Media Downloader.
///
/// Uses Inter for Latin scripts and Cairo for Arabic (Inter has no Arabic
/// glyphs). Falls back to the system font if Google Fonts is unavailable.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(ColorScheme colorScheme, {bool arabic = false}) {
    final baseTheme = TextTheme(
        displayLarge: TextStyle(color: colorScheme.onSurface),
        displayMedium: TextStyle(color: colorScheme.onSurface),
        displaySmall: TextStyle(color: colorScheme.onSurface),
        headlineLarge: TextStyle(color: colorScheme.onSurface),
        headlineMedium: TextStyle(color: colorScheme.onSurface),
        headlineSmall: TextStyle(color: colorScheme.onSurface),
        titleLarge: TextStyle(color: colorScheme.onSurface),
        titleMedium: TextStyle(color: colorScheme.onSurface),
        titleSmall: TextStyle(color: colorScheme.onSurface),
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurface),
        bodySmall: TextStyle(color: colorScheme.onSurfaceVariant),
        labelLarge: TextStyle(color: colorScheme.onSurface),
        labelMedium: TextStyle(color: colorScheme.onSurfaceVariant),
        labelSmall: TextStyle(color: colorScheme.onSurfaceVariant),
    );

    // Inter has no Arabic glyphs; Cairo covers both Arabic and Latin.
    final base = arabic
        ? GoogleFonts.cairoTextTheme(baseTheme)
        : GoogleFonts.interTextTheme(baseTheme);

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
