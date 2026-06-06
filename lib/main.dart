import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/constants/app_constants.dart';
import 'core/dependency_injection/injection_container.dart';
import 'core/themes/app_theme.dart';
import 'domain/entities/app_settings.dart';
import 'presentation/router/app_router.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';



/// Entry point for Media Downloader.
///
/// Initialises all dependencies, configures the desktop window,
/// then launches the Flutter app inside a [ProviderScope].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Window configuration ─────────────────────────────────────────────────────
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: const Size(AppConstants.defaultWindowWidth, AppConstants.defaultWindowHeight),
      minimumSize: const Size(AppConstants.minWindowWidth, AppConstants.minWindowHeight),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: AppConstants.appName,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  // ── Dependency injection ──────────────────────────────────────────────────────
  await configureDependencies();

  runApp(const ProviderScope(child: MediaDownloaderApp()));
}

/// Root widget of the application.
class MediaDownloaderApp extends ConsumerWidget {
  const MediaDownloaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final themeMode = settingsAsync.valueOrNull?.themeMode ?? AppThemeMode.system;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theming ─────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },

      // ── Routing ─────────────────────────────────────────────────────────────
      routerConfig: router,
    );
  }
}
