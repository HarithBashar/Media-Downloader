import 'package:flutter/material.dart';

/// Content area scaffold that wraps screen content with a top bar.
///
/// Unlike AppScaffold, this does NOT include the sidebar navigation —
/// that is handled by the ShellRoute in [AppRouter]. This widget only
/// provides the top bar with title and optional actions above the content.
class ContentScaffold extends StatelessWidget {
  const ContentScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top bar
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (actions != null) ...actions!,
            ],
          ),
        ),

        // Screen content
        Expanded(child: child),
      ],
    );
  }
}
