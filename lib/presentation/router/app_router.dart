import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/setup/setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/playlist/playlist_screen.dart';
import '../screens/queue/queue_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/sidebar_nav.dart';
import '../../core/dependency_injection/injection_container.dart';
import '../../core/services/binary_manager_service.dart';

/// Application router using go_router with ShellRoute.
///
/// The sidebar persists across navigation — only the content area transitions
/// with a smooth cross-fade + slide animation.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final binaryManager = getIt<BinaryManagerService>();
      final isSetupDone = binaryManager.isSetupComplete;
      final path = state.uri.path;

      // Allow splash screen to show
      if (path == AppRoutes.splash) return null;

      if (!isSetupDone && path != AppRoutes.setup) return AppRoutes.setup;
      if (isSetupDone && path == AppRoutes.setup) return AppRoutes.home;
      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      // Setup is a full-screen route (no sidebar)
      GoRoute(
        path: AppRoutes.setup,
        builder: (_, __) => const SetupScreen(),
      ),

      // Main shell: sidebar persists, only child content transitions
      ShellRoute(
        builder: (context, state, child) {
          return _AppShell(
            currentRoute: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, __) => const CustomTransitionPage(
              child: HomeScreen(),
              transitionsBuilder: _contentTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.playlist,
            pageBuilder: (_, __) => const CustomTransitionPage(
              child: PlaylistScreen(),
              transitionsBuilder: _contentTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.queue,
            pageBuilder: (_, __) => const CustomTransitionPage(
              child: QueueScreen(),
              transitionsBuilder: _contentTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.history,
            pageBuilder: (_, __) => const CustomTransitionPage(
              child: HistoryScreen(),
              transitionsBuilder: _contentTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, __) => const CustomTransitionPage(
              child: SettingsScreen(),
              transitionsBuilder: _contentTransition,
            ),
          ),
        ],
      ),
    ],
  );
});

/// Smooth cross-fade + subtle slide up transition for content area only.
Widget _contentTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final fadeIn = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  );
  final fadeOut = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeInCubic,
  );
  final slideIn = Tween<Offset>(
    begin: const Offset(0, 0.015),
    end: Offset.zero,
  ).animate(fadeIn);

  return FadeTransition(
    opacity: Tween<double>(begin: 0, end: 1).animate(fadeIn),
    child: FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.85).animate(fadeOut),
      child: SlideTransition(
        position: slideIn,
        child: child,
      ),
    ),
  );
}

/// The persistent app shell with sidebar + animated content area.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.currentRoute, required this.child});
  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar — never animates or rebuilds during navigation
          SidebarNav(currentRoute: currentRoute),

          // Content area — this is where the animated child goes
          Expanded(child: child),
        ],
      ),
    );
  }
}
