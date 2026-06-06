import 'app_exception.dart';

/// Represents a domain-layer failure after mapping from [AppException].
///
/// Use [Failure] in repository return types and view models to carry
/// user-facing messages without leaking implementation details.
sealed class Failure {
  const Failure(this.message);

  /// A user-friendly description of the failure.
  final String message;

  /// Converts an [AppException] to the appropriate [Failure] subtype.
  factory Failure.fromException(AppException e) => switch (e) {
        InvalidUrlException() => ValidationFailure(e.message),
        NetworkException() => NetworkFailure(e.message),
        PermissionException() => PermissionFailure(e.message),
        YtDlpException() => ProcessFailure(e.message),
        FfmpegException() => ProcessFailure(e.message),
        BinarySetupException() => SetupFailure(e.message),
        DiskSpaceException() => DiskSpaceFailure(e.message),
        StorageException() => StorageFailure(e.message),
        CancelledException() => CancelledFailure(e.message),
      };

  @override
  String toString() => '$runtimeType: $message';
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class ProcessFailure extends Failure {
  const ProcessFailure(super.message);
}

class SetupFailure extends Failure {
  const SetupFailure(super.message);
}

class DiskSpaceFailure extends Failure {
  const DiskSpaceFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class CancelledFailure extends Failure {
  const CancelledFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
