import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_languages.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/app_settings.dart';
import '../../l10n/enum_localizations.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../widgets/content_scaffold.dart';

/// Full settings screen with General, Downloads, yt-dlp, and Advanced sections.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return ContentScaffold(
      title: context.l10n.settingsTitle,
      child: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorLoadingSettings(e.toString()))),
        data: (settings) => _SettingsContent(settings: settings),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(settingsProvider.notifier);
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── General ──────────────────────────────────────────────────────────
          _SettingsSection(
            title: l10n.general,
            icon: Icons.tune_rounded,
            children: [
              _LanguageSetting(
                current: settings.language,
                onChanged: (code) => vm.updateField((s) => s.copyWith(language: code)),
              ),
              _ThemeSetting(
                current: settings.themeMode,
                onChanged: (mode) => vm.updateField((s) => s.copyWith(themeMode: mode)),
              ),
              _SwitchSetting(
                label: l10n.startOnStartup,
                subtitle: l10n.startOnStartupSubtitle,
                icon: Icons.start_rounded,
                value: settings.startOnStartup,
                onChanged: (v) => vm.updateField((s) => s.copyWith(startOnStartup: v)),
              ),
              _SwitchSetting(
                label: l10n.minimizeToTray,
                subtitle: l10n.minimizeToTraySubtitle,
                icon: Icons.minimize_rounded,
                value: settings.minimizeToTray,
                onChanged: (v) => vm.updateField((s) => s.copyWith(minimizeToTray: v)),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // ── Downloads ────────────────────────────────────────────────────────
          _SettingsSection(
            title: l10n.downloads,
            icon: Icons.download_rounded,
            children: [
              _DirectorySetting(
                label: l10n.defaultDownloadLocation,
                subtitle: settings.defaultOutputDirectory ?? l10n.systemDownloadsFolder,
                icon: Icons.folder_outlined,
                onTap: () async {
                  final result = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: l10n.selectDefaultDownloadLocation,
                  );
                  if (result != null) {
                    vm.updateField((s) => s.copyWith(defaultOutputDirectory: result));
                  }
                },
              ),
              _SliderSetting(
                label: l10n.concurrentDownloads,
                subtitle: l10n.concurrentDownloadsSubtitle(settings.maxConcurrentDownloads),
                icon: Icons.multiple_stop_rounded,
                value: settings.maxConcurrentDownloads.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) =>
                    vm.updateField((s) => s.copyWith(maxConcurrentDownloads: v.round())),
              ),
              _SliderSetting(
                label: l10n.retryCountLabel,
                subtitle: l10n.retryCountSubtitle(settings.retryCount),
                icon: Icons.replay_rounded,
                value: settings.retryCount.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (v) =>
                    vm.updateField((s) => s.copyWith(retryCount: v.round())),
              ),
              _SpeedLimitSetting(
                current: settings.speedLimitKbps,
                onChanged: (v) => vm.updateField((s) => s.copyWith(speedLimitKbps: v)),
              ),
              _SwitchSetting(
                label: l10n.openFileAfterDownload,
                subtitle: l10n.openFileAfterDownloadSubtitle,
                icon: Icons.open_in_new_rounded,
                value: settings.autoOpenFile,
                onChanged: (v) => vm.updateField((s) => s.copyWith(autoOpenFile: v)),
              ),
              _SwitchSetting(
                label: l10n.openFolderAfterDownload,
                subtitle: l10n.openFolderAfterDownloadSubtitle,
                icon: Icons.folder_open_rounded,
                value: settings.autoOpenFolder,
                onChanged: (v) => vm.updateField((s) => s.copyWith(autoOpenFolder: v)),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // ── yt-dlp ───────────────────────────────────────────────────────────
          _SettingsSection(
            title: 'yt-dlp',
            icon: Icons.terminal_rounded,
            children: [
              _SwitchSetting(
                label: l10n.autoUpdateYtDlp,
                subtitle: l10n.autoUpdateYtDlpSubtitle,
                icon: Icons.system_update_alt_rounded,
                value: settings.autoUpdateYtDlp,
                onChanged: (v) => vm.updateField((s) => s.copyWith(autoUpdateYtDlp: v)),
              ),
              _SwitchSetting(
                label: l10n.embedMetadataByDefault,
                subtitle: l10n.embedMetadataByDefaultSubtitle,
                icon: Icons.info_outline_rounded,
                value: settings.embedMetadataDefault,
                onChanged: (v) => vm.updateField((s) => s.copyWith(embedMetadataDefault: v)),
              ),
              _SwitchSetting(
                label: l10n.useDownloadArchive,
                subtitle: l10n.useDownloadArchiveSubtitle,
                icon: Icons.archive_outlined,
                value: settings.useDownloadArchive,
                onChanged: (v) => vm.updateField((s) => s.copyWith(useDownloadArchive: v)),
              ),
              _TextFieldSetting(
                label: l10n.customYtDlpArgs,
                subtitle: l10n.customYtDlpArgsSubtitle,
                icon: Icons.code_rounded,
                value: settings.customYtDlpArgs,
                hint: l10n.customYtDlpArgsHint,
                onChanged: (v) => vm.updateField((s) => s.copyWith(customYtDlpArgs: v)),
              ),
              _TextFieldSetting(
                label: l10n.proxyUrl,
                subtitle: l10n.proxyUrlSubtitle,
                icon: Icons.vpn_lock_rounded,
                value: settings.proxyUrl,
                hint: 'socks5://127.0.0.1:1080',
                onChanged: (v) => vm.updateField((s) => s.copyWith(proxyUrl: v)),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // ── Advanced ─────────────────────────────────────────────────────────
          _SettingsSection(
            title: l10n.advanced,
            icon: Icons.settings_rounded,
            children: [
              _SwitchSetting(
                label: l10n.debugLogging,
                subtitle: l10n.debugLoggingSubtitle,
                icon: Icons.bug_report_outlined,
                value: settings.debugLogging,
                onChanged: (v) => vm.updateField((s) => s.copyWith(debugLogging: v)),
              ),
              _DangerZone(
                onReset: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.resetAllSettingsQuestion),
                      content: Text(l10n.resetAllSettingsConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                          child: Text(l10n.reset),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(settingsProvider.notifier).resetToDefaults();
                  }
                },
              ),
            ].animate().fadeIn(delay: 300.ms, duration: 300.ms),
          ),
          
          const SizedBox(height: 32),

          // ── About Developer ────────────────────────────────────────────────────
          const _AboutDeveloperSection().animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.05),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Section container ────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          // Transparent Material so ListTile ink/background paints above the
          // container's color instead of being hidden by it.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: children.expand((w) sync* {
                yield w;
                if (w != children.last) {
                  yield const Divider(height: 1, indent: 16, endIndent: 16);
                }
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Setting row types ────────────────────────────────────────────────────────

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primary),
    );
  }
}

class _ThemeSetting extends StatelessWidget {
  const _ThemeSetting({required this.current, required this.onChanged});
  final AppThemeMode current;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.palette_outlined, size: 20),
      title: Text(l10n.theme, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(current.localizedLabel(l10n)),
      trailing: SegmentedButton<AppThemeMode>(
        segments: AppThemeMode.values.map((m) => ButtonSegment(
          value: m,
          label: Text(m.localizedLabel(l10n), style: const TextStyle(fontSize: 12)),
        )).toList(),
        selected: {current},
        onSelectionChanged: (s) => onChanged(s.first),
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

/// Language selector for switching the app's UI language.
class _LanguageSetting extends StatelessWidget {
  const _LanguageSetting({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = languageForCode(current).code;
    return ListTile(
      leading: const Icon(Icons.language_rounded, size: 20),
      title: Text(context.l10n.language, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(languageForCode(current).nativeName),
      trailing: SegmentedButton<String>(
        segments: supportedLanguages
            .map((lang) => ButtonSegment(
                  value: lang.code,
                  label: Text(lang.nativeName, style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _DirectorySetting extends StatelessWidget {
  const _DirectorySetting({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SpeedLimitSetting extends StatelessWidget {
  const _SpeedLimitSetting({required this.current, required this.onChanged});
  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.speed_rounded, size: 20),
      title: Text(l10n.speedLimit, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(current == 0 ? l10n.unlimited : l10n.speedLimitValue(current)),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          controller: TextEditingController(text: current == 0 ? '' : current.toString()),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: l10n.speedLimitHint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            isDense: true,
          ),
          onSubmitted: (v) => onChanged(int.tryParse(v) ?? 0),
        ),
      ),
    );
  }
}

class _TextFieldSetting extends StatefulWidget {
  const _TextFieldSetting({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.hint,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_TextFieldSetting> createState() => _TextFieldSettingState();
}

class _TextFieldSettingState extends State<_TextFieldSetting> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onSubmitted: widget.onChanged,
            decoration: InputDecoration(hintText: widget.hint, isDense: true),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.dangerZone,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: Text(context.l10n.resetAllSettingsToDefaults),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── About Developer ─────────────────────────────────────────────────────────

class _AboutDeveloperSection extends StatefulWidget {
  const _AboutDeveloperSection();

  @override
  State<_AboutDeveloperSection> createState() => _AboutDeveloperSectionState();
}

class _AboutDeveloperSectionState extends State<_AboutDeveloperSection> {
  bool _isHovered = false;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceContainer.withOpacity(_isHovered ? .6 : 1),
              Theme.of(context).colorScheme.surfaceContainer.withOpacity(_isHovered ? .6 : 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _isHovered 
                ? colorScheme.primary.withOpacity(0.5) 
                : colorScheme.outlineVariant.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network('https://avatars.githubusercontent.com/u/25960528?v=4')
                  )
                ).animate(target: _isHovered ? 1 : 0).scaleXY(end: 1.05, duration: 200.ms),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harith Bashar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.leadDeveloper,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SocialButton(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  url: 'https://github.com/HarithBashar',
                  onTap: () => _launchUrl('https://github.com/HarithBashar'),
                ),
                _SocialButton(
                  icon: Icons.work_outline_rounded,
                  label: 'LinkedIn',
                  url: 'https://www.linkedin.com/in/harithbashar/',
                  onTap: () => _launchUrl('https://www.linkedin.com/in/harithbashar/'),
                ),
                _SocialButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  url: 'https://www.instagram.com/harith.bashar/',
                  onTap: () => _launchUrl('https://www.instagram.com/harith.bashar/'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.onTap,
  });
  
  final IconData icon;
  final String label;
  final String url;
  final VoidCallback onTap;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? colorScheme.primary : colorScheme.outlineVariant,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _isHovered ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ).animate(target: _isHovered ? 1 : 0).moveY(end: -2, duration: 150.ms),
    );
  }
}
