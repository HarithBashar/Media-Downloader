import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/url_validator.dart';
import '../../../core/utils/file_utils.dart';
import '../../../domain/entities/download_enums.dart';
import '../../viewmodels/download_queue_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../widgets/content_scaffold.dart';

/// Main download screen.
///
/// Contains: URL input, drag-and-drop, type/quality selectors,
/// output directory picker, and the primary download action.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _urlController = TextEditingController();
  final _filenameController = TextEditingController();
  final _urlFocusNode = FocusNode();
  bool _isDraggingOver = false;

  DownloadType _downloadType = DownloadType.video;
  VideoQuality _videoQuality = VideoQuality.best;
  AudioQuality _audioQuality = AudioQuality.best;
  String? _outputDirectory;
  bool _embedThumbnail = false;
  bool _embedMetadata = true;
  bool _downloadSubtitles = false;
  bool _embedSubtitles = false;
  String _subtitleLanguage = 'en';
  bool _sponsorBlock = false;
  String? _urlError;

  @override
  void initState() {
    super.initState();
    _loadDefaultDirectory();
    _setupClipboardDetection();
  }

  Future<void> _loadDefaultDirectory() async {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings?.defaultOutputDirectory != null) {
      setState(() => _outputDirectory = settings!.defaultOutputDirectory);
    } else {
      final dir = await FileUtils.getDefaultDownloadsDirectory();
      if (mounted) setState(() => _outputDirectory = dir.path);
    }
  }

  void _setupClipboardDetection() {
    _urlFocusNode.addListener(() {
      if (_urlFocusNode.hasFocus && _urlController.text.isEmpty) {
        _checkClipboard();
      }
    });
  }

  Future<void> _checkClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && UrlValidator.isValidUrl(data!.text!)) {
      if (mounted && _urlController.text.isEmpty) {
        setState(() => _urlController.text = UrlValidator.sanitise(data.text!));
      }
    }
  }

  void _validateUrl(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _urlError = null;
      } else if (!UrlValidator.isValidUrl(value)) {
        _urlError = 'Please enter a valid URL';
      } else {
        _urlError = null;
      }
    });
  }

  Future<void> _pickOutputDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Download Location',
      initialDirectory: _outputDirectory,
    );
    if (result != null) {
      setState(() => _outputDirectory = result);
      // Save it globally so it's remembered across restarts and screen switches
      ref.read(settingsProvider.notifier).updateField(
        (s) => s.copyWith(defaultOutputDirectory: result),
      );
    }
  }

  void _startDownload() {
    final url = _urlController.text.trim();
    if (!UrlValidator.isValidUrl(url)) {
      setState(() => _urlError = 'Please enter a valid URL');
      return;
    }
    if (_outputDirectory == null) return;

    ref.read(downloadQueueProvider.notifier).enqueue(
      url: UrlValidator.sanitise(url),
      type: _downloadType,
      videoQuality: _videoQuality,
      audioQuality: _audioQuality,
      outputDirectory: _outputDirectory!,
      embedThumbnail: _embedThumbnail,
      embedMetadata: _embedMetadata,
      downloadSubtitles: _downloadSubtitles,
      embedSubtitles: _embedSubtitles,
      subtitleLanguage: _downloadSubtitles ? _subtitleLanguage : null,
      sponsorBlock: _sponsorBlock,
      customFilename: _filenameController.text.trim().isEmpty
          ? null
          : _filenameController.text.trim(),
    );

    setState(() {
      _urlController.clear();
      _filenameController.clear();
    });

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Download added to queue'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _filenameController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ContentScaffold(
      title: 'Download',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Text(
              'Add Download',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
            const SizedBox(height: 4),
            Text(
              'Paste a URL, drag & drop, or let us detect from your clipboard',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 32),

            // ── URL Input with Drag & Drop ──────────────────────────────────
            DropTarget(
              onDragDone: (details) {
                // Handle dropped text (desktop_drop provides files; URLs come as text)
              },
              onDragEntered: (_) => setState(() => _isDraggingOver = true),
              onDragExited: (_) => setState(() => _isDraggingOver = false),
              child: AnimatedContainer(
                duration: AppConstants.shortAnimation,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
                  border: Border.all(
                    color: _isDraggingOver ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: _UrlInputField(
                  controller: _urlController,
                  focusNode: _urlFocusNode,
                  errorText: _urlError,
                  onChanged: _validateUrl,
                  onSubmitted: (_) => _startDownload(),
                  isDragging: _isDraggingOver,
                ),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.05),

            const SizedBox(height: 24),

            // ── Type and Quality Row ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SectionCard(
                    label: 'Type',
                    child: _DownloadTypeSelector(
                      selected: _downloadType,
                      onChanged: (t) => setState(() => _downloadType = t),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _SectionCard(
                    label: 'Quality',
                    child: _downloadType == DownloadType.video
                        ? _VideoQualitySelector(
                            selected: _videoQuality,
                            onChanged: (q) => setState(() => _videoQuality = q),
                          )
                        : _AudioQualitySelector(
                            selected: _audioQuality,
                            onChanged: (q) => setState(() => _audioQuality = q),
                          ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // ── Output Directory ──────────────────────────────────────────────
            _SectionCard(
              label: 'Save to',
              child: _OutputDirectoryPicker(
                path: _outputDirectory,
                onTap: _pickOutputDirectory,
              ),
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // ── Custom Filename ────────────────────────────────────────────────
            _SectionCard(
              label: 'Filename',
              child: TextField(
                controller: _filenameController,
                decoration: InputDecoration(
                  hintText: 'Leave empty to use original title',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.edit_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  fillColor: colorScheme.surfaceContainerLow,
                ),
                style: textTheme.bodyLarge,
              ),
            ).animate().fadeIn(delay: 275.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // ── Options ───────────────────────────────────────────────────────
            _SectionCard(
              label: 'Options',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _OptionChip(
                        label: 'Embed Thumbnail',
                        icon: Icons.image_outlined,
                        selected: _embedThumbnail,
                        onToggle: (v) => setState(() => _embedThumbnail = v),
                      ),
                      _OptionChip(
                        label: 'Embed Metadata',
                        icon: Icons.info_outline_rounded,
                        selected: _embedMetadata,
                        onToggle: (v) => setState(() => _embedMetadata = v),
                      ),
                      _OptionChip(
                        label: 'Subtitles',
                        icon: Icons.subtitles_outlined,
                        selected: _downloadSubtitles,
                        onToggle: (v) => setState(() => _downloadSubtitles = v),
                      ),
                      _OptionChip(
                        label: 'SponsorBlock',
                        icon: Icons.block_outlined,
                        selected: _sponsorBlock,
                        onToggle: (v) => setState(() => _sponsorBlock = v),
                      ),
                    ],
                  ),

                  // Subtitle options (shown when subtitles are enabled)
                  if (_downloadSubtitles) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subtitle Settings',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // Language dropdown
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _subtitleLanguage,
                                  decoration: InputDecoration(
                                    labelText: 'Language',
                                    labelStyle: textTheme.bodySmall,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: AppConstants.subtitleLanguages.map((lang) {
                                    return DropdownMenuItem<String>(
                                      value: lang['code'],
                                      child: Text(lang['name']!, style: textTheme.bodyMedium),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _subtitleLanguage = value);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Embed subtitles toggle
                              _OptionChip(
                                label: 'Embed in Video',
                                icon: Icons.closed_caption_rounded,
                                selected: _embedSubtitles,
                                onToggle: (v) => setState(() => _embedSubtitles = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 32),

            // ── Download Button ───────────────────────────────────────────────
            _DownloadButton(onPressed: _startDownload)
                .animate()
                .fadeIn(delay: 350.ms, duration: 400.ms)
                .scale(begin: const Offset(0.97, 0.97), duration: 400.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _UrlInputField extends StatelessWidget {
  const _UrlInputField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.isDragging,
    this.errorText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool isDragging;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: isDragging
            ? 'Drop URL here…'
            : 'Paste URL here (YouTube, Vimeo, TikTok, and 1000+ more)',
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            isDragging ? Icons.link_rounded : Icons.link_rounded,
            color: isDragging ? AppColors.primary : colorScheme.onSurfaceVariant,
          ),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () => controller.clear(),
                tooltip: 'Clear',
              )
            : IconButton(
                icon: const Icon(Icons.content_paste_rounded),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) controller.text = data!.text!;
                },
                tooltip: 'Paste from clipboard',
              ),
        errorText: errorText,
        fillColor: isDragging
            ? AppColors.primary.withValues(alpha: 0.05)
            : colorScheme.surfaceContainerLow,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DownloadTypeSelector extends StatelessWidget {
  const _DownloadTypeSelector({required this.selected, required this.onChanged});
  final DownloadType selected;
  final ValueChanged<DownloadType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: DownloadType.values.map((type) {
        final isSelected = selected == type;
        return _TypeOption(
          type: type,
          isSelected: isSelected,
          onTap: () => onChanged(type),
        );
      }).toList(),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({required this.type, required this.isSelected, required this.onTap});
  final DownloadType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = type == DownloadType.video ? Icons.videocam_rounded : Icons.music_note_rounded;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              type.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? AppColors.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoQualitySelector extends StatelessWidget {
  const _VideoQualitySelector({required this.selected, required this.onChanged});
  final VideoQuality selected;
  final ValueChanged<VideoQuality> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VideoQuality.values.where((q) => q != VideoQuality.custom).map((q) {
        return _QualityChip(
          label: q.label,
          isSelected: selected == q,
          onTap: () => onChanged(q),
        );
      }).toList(),
    );
  }
}

class _AudioQualitySelector extends StatelessWidget {
  const _AudioQualitySelector({required this.selected, required this.onChanged});
  final AudioQuality selected;
  final ValueChanged<AudioQuality> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AudioQuality.values.map((q) {
        return _QualityChip(
          label: q.label,
          isSelected: selected == q,
          onTap: () => onChanged(q),
        );
      }).toList(),
    );
  }
}

class _QualityChip extends StatelessWidget {
  const _QualityChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _OutputDirectoryPicker extends StatelessWidget {
  const _OutputDirectoryPicker({required this.path, required this.onTap});
  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    path ?? 'No folder selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: path != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.drive_folder_upload_outlined, size: 18),
          label: const Text('Browse'),
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onToggle,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onToggle(!selected),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_rounded : icon,
              size: 16,
              color: selected ? AppColors.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? AppColors.primary : colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  const _DownloadButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _hovering ? AppColors.primary.withValues(alpha: 0.85) : AppColors.primary,
              _hovering ? AppColors.secondary.withValues(alpha: 0.85) : AppColors.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            splashColor: Colors.white.withValues(alpha: 0.1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Start Download',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
