import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/themes/app_colors.dart';

/// Displays a centered empty state with an icon, title, and subtitle.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary.withValues(alpha: 0.5), size: 36),
          ).animate().scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 20),

          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

          if (action != null) ...[
            const SizedBox(height: 24),
            action!.animate().fadeIn(delay: 200.ms, duration: 300.ms),
          ],
        ],
      ),
    );
  }
}
