/// Download status state machine for a single download item.
library;

/// All possible states of a download operation.
enum DownloadStatus {
  /// Queued but not yet started.
  waiting,

  /// Fetching metadata and preparing the download.
  preparing,

  /// Actively downloading bytes.
  downloading,

  /// Converting audio format (e.g. webm → mp3).
  converting,

  /// Merging separate video and audio streams.
  merging,

  /// Download finished successfully.
  completed,

  /// Download encountered an unrecoverable error.
  failed,

  /// Download paused by the user.
  paused,

  /// Download cancelled by the user.
  cancelled;

  /// Whether the download is currently active (running process).
  bool get isActive => this == downloading || this == preparing || this == converting || this == merging;

  /// Whether the download is in a terminal state.
  bool get isTerminal => this == completed || this == failed || this == cancelled;

  /// Whether the user can pause this download.
  bool get canPause => isActive;

  /// Whether the user can resume this download.
  bool get canResume => this == paused;

  /// Whether the download can be retried.
  bool get canRetry => this == failed || this == cancelled;

  /// Human-readable label.
  String get label => switch (this) {
        waiting => 'Waiting',
        preparing => 'Preparing',
        downloading => 'Downloading',
        converting => 'Converting',
        merging => 'Merging',
        completed => 'Completed',
        failed => 'Failed',
        paused => 'Paused',
        cancelled => 'Cancelled',
      };
}

/// Download media type.
enum DownloadType {
  video,
  audio;

  String get label => name[0].toUpperCase() + name.substring(1);
}

/// Video quality presets.
enum VideoQuality {
  best('Best Available', 'bestvideo+bestaudio/best'),
  high('High (1080p)', 'bestvideo[height<=1080]+bestaudio/best[height<=1080]'),
  medium('Medium (720p)', 'bestvideo[height<=720]+bestaudio/best[height<=720]'),
  low('Low (480p)', 'bestvideo[height<=480]+bestaudio/best[height<=480]'),
  custom('Custom Format', '');

  const VideoQuality(this.label, this.formatString);

  final String label;
  final String formatString;
}

/// Audio quality presets.
enum AudioQuality {
  best('Best Available', '0'),
  mp3_320('MP3 320kbps', '0'),
  mp3_256('MP3 256kbps', '5'),
  mp3_192('MP3 192kbps', '2'),
  mp3_128('MP3 128kbps', '5'),
  original('Original Audio', '0');

  const AudioQuality(this.label, this.bitrateArg);

  final String label;
  final String bitrateArg;
}
