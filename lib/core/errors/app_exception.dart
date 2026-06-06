/// Typed error hierarchy for Media Downloader.
///
/// All errors originating from the application domain extend [AppException].
/// Each subclass carries enough context for error messages and recovery actions.
library;

/// Base class for all application-level exceptions.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Human-readable error description.
  final String message;

  /// Optional underlying error / stack trace.
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Thrown when a provided URL is invalid or unsupported.
class InvalidUrlException extends AppException {
  const InvalidUrlException(super.message, {super.cause});
}

/// Thrown when network connectivity fails or times out.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

/// Thrown when an OS-level permission is missing (e.g. file access).
class PermissionException extends AppException {
  const PermissionException(super.message, {super.cause});
}

/// Thrown when a yt-dlp subprocess returns a non-zero exit code.
class YtDlpException extends AppException {
  const YtDlpException(super.message, {super.cause, this.exitCode, this.stderr});

  final int? exitCode;
  final String? stderr;
}

/// Thrown when FFmpeg fails during conversion or merging.
class FfmpegException extends AppException {
  const FfmpegException(super.message, {super.cause, this.exitCode});

  final int? exitCode;
}

/// Thrown when the binary manager fails to download/verify yt-dlp or FFmpeg.
class BinarySetupException extends AppException {
  const BinarySetupException(super.message, {super.cause});
}

/// Thrown when there is insufficient disk space.
class DiskSpaceException extends AppException {
  const DiskSpaceException(super.message, {super.cause, this.required, this.available});

  /// Required bytes.
  final int? required;

  /// Available bytes.
  final int? available;
}

/// Thrown when a local storage read/write fails.
class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

/// Thrown when a download is cancelled by the user.
class CancelledException extends AppException {
  const CancelledException([super.message = 'Download cancelled by user']);
}
