import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Provides both light and dark [ThemeData] for the application.
///
/// Inspired by the clean design language of Arc Browser, Raycast, and Linear.
/// Uses Material 3 with custom color overrides for a premium desktop feel.
class AppTheme {
  AppTheme._();

  static ThemeData light([Locale? locale]) =>
      _buildTheme(brightness: Brightness.light, locale: locale);
  static ThemeData dark([Locale? locale]) =>
      _buildTheme(brightness: Brightness.dark, locale: locale);

  static ThemeData _buildTheme({required Brightness brightness, Locale? locale}) {
    final isDark = brightness == Brightness.dark;
    final AppSurfaceColors colors = isDark ? AppColors.dark : AppColors.light;
    final bool arabic = locale?.languageCode == 'ar';

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accentContainer,
      onTertiaryContainer: AppColors.onAccentContainer,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainerLowest: colors.surfaceLowest,
      surfaceContainerLow: colors.surfaceLow,
      surfaceContainer: colors.surfaceContainer,
      surfaceContainerHigh: colors.surfaceHigh,
      surfaceContainerHighest: colors.surfaceHighest,
      onSurfaceVariant: colors.onSurfaceVariant,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.onInverseSurface,
      inversePrimary: AppColors.primaryContainer,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(colorScheme, arabic: arabic),

      // ─── Scaffold ───────────────────────────────────────────────────────────
      scaffoldBackgroundColor: colors.background,

      // ─── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: colors.outline.withValues(alpha: 0.3),
        titleTextStyle: AppTypography.textTheme(colorScheme, arabic: arabic).titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─── Card ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── Input ───────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ─── Elevated Button ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── FilledButton ────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ─── OutlinedButton ──────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: colors.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ─── TextButton ──────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),

      // ─── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ─── ListTile ────────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      // ─── SnackBar ────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // ─── Tooltip ─────────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(
          color: isDark ? Colors.black : Colors.white,
          fontSize: 12,
        ),
        waitDuration: const Duration(milliseconds: 600),
      ),

      // ─── Chip ────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: colors.outlineVariant),
      ),

      // ─── Progress Indicator ──────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Colors.transparent,
      ),

      // ─── Icon ────────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: colors.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}
