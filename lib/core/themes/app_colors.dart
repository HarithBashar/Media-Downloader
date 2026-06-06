import 'package:flutter/material.dart';

/// Defines the complete color palette for Media Downloader.
///
/// Uses a cohesive indigo/violet primary with warm accent colors.
/// [AppSurfaceColors] provides a common interface for surface tokens.
class AppColors {
  AppColors._();

  // ─── Brand colors ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryContainer = Color(0xFFEEF2FF);
  static const Color onPrimaryContainer = Color(0xFF3730A3);

  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryContainer = Color(0xFFF5F3FF);
  static const Color onSecondaryContainer = Color(0xFF5B21B6);

  static const Color accent = Color(0xFF06B6D4);
  static const Color accentContainer = Color(0xFFECFEFF);
  static const Color onAccentContainer = Color(0xFF0E7490);

  // ─── Status colors ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // ─── Download state colors ───────────────────────────────────────────────────
  static const Color stateWaiting = Color(0xFF94A3B8);
  static const Color statePreparing = Color(0xFFF59E0B);
  static const Color stateDownloading = Color(0xFF6366F1);
  static const Color stateConverting = Color(0xFF8B5CF6);
  static const Color stateMerging = Color(0xFF06B6D4);
  static const Color stateCompleted = Color(0xFF10B981);
  static const Color stateFailed = Color(0xFFEF4444);
  static const Color statePaused = Color(0xFFF59E0B);
  static const Color stateCancelled = Color(0xFF6B7280);

  // ─── Surface token accessors ─────────────────────────────────────────────────
  static AppSurfaceColors get light => const _LightColors();
  static AppSurfaceColors get dark => const _DarkColors();
}

/// Common interface for surface color tokens (light & dark).
abstract class AppSurfaceColors {
  const AppSurfaceColors();
  Color get background;
  Color get surface;
  Color get surfaceLowest;
  Color get surfaceLow;
  Color get surfaceContainer;
  Color get surfaceHigh;
  Color get surfaceHighest;
  Color get onSurface;
  Color get onSurfaceVariant;
  Color get outline;
  Color get outlineVariant;
  Color get inverseSurface;
  Color get onInverseSurface;
  Color get sidebarBackground;
  Color get sidebarBorder;
}

/// Light mode surface tokens.
class _LightColors extends AppSurfaceColors {
  const _LightColors();

  @override Color get background => const Color(0xFFF8F9FC);
  @override Color get surface => const Color(0xFFFFFFFF);
  @override Color get surfaceLowest => const Color(0xFFFFFFFF);
  @override Color get surfaceLow => const Color(0xFFF3F4F6);
  @override Color get surfaceContainer => const Color(0xFFF9FAFB);
  @override Color get surfaceHigh => const Color(0xFFE5E7EB);
  @override Color get surfaceHighest => const Color(0xFFD1D5DB);
  @override Color get onSurface => const Color(0xFF111827);
  @override Color get onSurfaceVariant => const Color(0xFF6B7280);
  @override Color get outline => const Color(0xFFD1D5DB);
  @override Color get outlineVariant => const Color(0xFFE5E7EB);
  @override Color get inverseSurface => const Color(0xFF1F2937);
  @override Color get onInverseSurface => const Color(0xFFF9FAFB);
  @override Color get sidebarBackground => const Color(0xFFFFFFFF);
  @override Color get sidebarBorder => const Color(0xFFE5E7EB);
}

/// Dark mode surface tokens.
class _DarkColors extends AppSurfaceColors {
  const _DarkColors();

  @override Color get background => const Color(0xFF0F1117);
  @override Color get surface => const Color(0xFF1A1D27);
  @override Color get surfaceLowest => const Color(0xFF0F1117);
  @override Color get surfaceLow => const Color(0xFF151821);
  @override Color get surfaceContainer => const Color(0xFF1E2130);
  @override Color get surfaceHigh => const Color(0xFF252838);
  @override Color get surfaceHighest => const Color(0xFF2D3142);
  @override Color get onSurface => const Color(0xFFF1F2F6);
  @override Color get onSurfaceVariant => const Color(0xFF9CA3AF);
  @override Color get outline => const Color(0xFF374151);
  @override Color get outlineVariant => const Color(0xFF1F2937);
  @override Color get inverseSurface => const Color(0xFFF1F2F6);
  @override Color get onInverseSurface => const Color(0xFF1A1D27);
  @override Color get sidebarBackground => const Color(0xFF13151F);
  @override Color get sidebarBorder => const Color(0xFF1F2937);
}
