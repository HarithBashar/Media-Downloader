import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../viewmodels/binary_setup_viewmodel.dart';

/// First-launch screen that shows binary download progress.
///
/// After setup completes, automatically navigates to the main app.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Start setup on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final setupVM = ref.read(binarySetupProvider.notifier);
      final state = ref.read(binarySetupProvider);
      if (state.status == SetupStatus.idle) {
        // BinarySetupViewModel will check isSetupComplete internally
        setupVM.startIfNeeded();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(binarySetupProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Navigate when done
    ref.listen(binarySetupProvider, (prev, next) {
      if (next.isDone && !(prev?.isDone ?? false)) {
        Future.delayed(const Duration(milliseconds: 800), () {
          // ignore: use_build_context_synchronously
          if (mounted) context.go(AppRoutes.home);
        });
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icon
              _AnimatedLogo(pulseController: _pulseController)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 40),

              // App Name
              Text(
                AppConstants.appName,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 8),

              Text(
                'Setting up your download engine…',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 48),

              // Progress section
              AnimatedSwitcher(
                duration: AppConstants.mediumAnimation,
                child: setupState.hasFailed
                    ? _ErrorCard(
                        error: setupState.error ?? 'Setup failed.',
                        onRetry: () => ref.read(binarySetupProvider.notifier).runSetup(),
                      )
                    : _ProgressSection(state: setupState),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.pulseController});
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, __) {
        final glow = 0.3 + pulseController.value * 0.3;
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: glow),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.download_rounded,
            color: Colors.white,
            size: 48,
          ),
        );
      },
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.state});
  final SetupState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDone = state.isDone;

    return Column(
      children: [
        // Status message
        Text(
          state.message,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: state.progress > 0 ? state.progress : null,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDone ? AppColors.success : AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          isDone ? 'Ready!' : '${(state.progress * 100).toInt()}%',
          style: textTheme.labelMedium?.copyWith(
            color: isDone ? AppColors.success : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
          const SizedBox(height: 12),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Setup'),
          ),
        ],
      ),
    );
  }
}
