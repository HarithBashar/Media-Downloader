import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/dependency_injection/injection_container.dart';
import '../../../core/l10n/app_languages.dart';
import '../../../core/services/binary_manager_service.dart';
import '../../../core/themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      final binaryManager = getIt<BinaryManagerService>();
      if (binaryManager.isSetupComplete) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.setup);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
            .animate()
            .scaleXY(begin: 0.8, end: 1.0, duration: 800.ms, curve: Curves.easeOutCubic)
            .fadeIn(duration: 800.ms)
            .shimmer(delay: 800.ms, duration: 1200.ms, color: Colors.white.withOpacity(0.3)),
            
            const SizedBox(height: 32),
            
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            )
            .animate()
            .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
            .fadeIn(delay: 200.ms, duration: 600.ms),
            
            const SizedBox(height: 12),
            
            Text(
              context.l10n.splashTagline,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
