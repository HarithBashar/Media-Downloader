import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dependency_injection/injection_container.dart';
import '../../core/services/binary_manager_service.dart';

/// State for the binary setup process.
class SetupState {
  const SetupState({
    this.status = SetupStatus.idle,
    this.message = 'Initializing…',
    this.progress = 0.0,
    this.error,
  });

  final SetupStatus status;
  final String message;
  final double progress;
  final String? error;

  bool get isDone => status == SetupStatus.done;
  bool get hasFailed => status == SetupStatus.failed;
  bool get isRunning => status == SetupStatus.running;

  SetupState copyWith({
    SetupStatus? status,
    String? message,
    double? progress,
    String? error,
  }) {
    return SetupState(
      status: status ?? this.status,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

enum SetupStatus { idle, running, done, failed }

/// ViewModel for the first-launch binary setup screen.
class BinarySetupViewModel extends Notifier<SetupState> {
  late BinaryManagerService _binaryManager;

  @override
  SetupState build() {
    _binaryManager = getIt<BinaryManagerService>();
    return const SetupState();
  }

  /// Runs the full binary setup and notifies progress.
  Future<void> runSetup() async {
    state = state.copyWith(status: SetupStatus.running, progress: 0.0);
    try {
      await _binaryManager.setup(
        onProgress: (message, progress) {
          state = state.copyWith(
            message: message,
            progress: progress,
            status: SetupStatus.running,
          );
        },
      );

      // Register download dependencies now that paths are known
      registerDownloadDependencies(
        ytDlpPath: _binaryManager.ytDlpPath!,
        ffmpegPath: _binaryManager.ffmpegPath,
      );

      state = state.copyWith(
        status: SetupStatus.done,
        message: 'Ready!',
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: SetupStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Checks install state and either runs setup or initialises from existing binaries.
  void startIfNeeded() {
    if (_binaryManager.isSetupComplete) {
      initFromExistingInstall();
    } else {
      runSetup();
    }
  }

  /// For when binaries are already installed — just register dependencies.
  void initFromExistingInstall() {
    final ytDlpPath = _binaryManager.ytDlpPath;
    if (ytDlpPath != null) {
      registerDownloadDependencies(
        ytDlpPath: ytDlpPath,
        ffmpegPath: _binaryManager.ffmpegPath,
      );
    }
    state = state.copyWith(status: SetupStatus.done, progress: 1.0);
  }
}

final binarySetupProvider = NotifierProvider<BinarySetupViewModel, SetupState>(
  BinarySetupViewModel.new,
);
