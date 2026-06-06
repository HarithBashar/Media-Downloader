import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/binary_manager_service.dart';
import '../../data/datasources/local/history_local_datasource.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/process/ytdlp_process_datasource.dart';
import '../../data/repositories/download_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/download_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/settings_repository.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Registers all application dependencies.
///
/// Call once at app startup before [runApp].
/// Uses [SharedPreferences] as an async dependency that must be awaited first.
Future<void> configureDependencies() async {
  // ── External ─────────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 100,
        colors: true,
        printEmojis: true,
      ),
      level: Level.debug,
    ),
  );

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
    ));
    return dio;
  });

  // ── Core Services ─────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<BinaryManagerService>(
    () => BinaryManagerService(
      prefs: getIt<SharedPreferences>(),
      dio: getIt<Dio>(),
      logger: getIt<Logger>(),
    ),
  );

  // ── Data Sources ──────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<HistoryLocalDatasource>(
    () => HistoryLocalDatasource(),
  );

  getIt.registerLazySingleton<SettingsLocalDatasource>(
    () => SettingsLocalDatasource(prefs: getIt<SharedPreferences>()),
  );

  // YtDlpProcessDatasource is registered after setup completes
  // (needs yt-dlp path which isn't available until binary is downloaded)

  // ── Repositories ──────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(datasource: getIt<HistoryLocalDatasource>()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(datasource: getIt<SettingsLocalDatasource>()),
  );

  // ── Early registration (returning users) ─────────────────────────────────────
  // If setup was completed in a previous session, register download dependencies
  // immediately so they're available when the ShellRoute builds the sidebar.
  final binaryManager = getIt<BinaryManagerService>();
  if (binaryManager.isSetupComplete) {
    final ytDlpPath = binaryManager.ytDlpPath;
    if (ytDlpPath != null) {
      registerDownloadDependencies(
        ytDlpPath: ytDlpPath,
        ffmpegPath: binaryManager.ffmpegPath,
      );
    }
  }
}

/// Registers [YtDlpProcessDatasource] and [DownloadRepository] after binary paths are known.
void registerDownloadDependencies({required String ytDlpPath, String? ffmpegPath}) {
  if (!getIt.isRegistered<YtDlpProcessDatasource>()) {
    getIt.registerSingleton<YtDlpProcessDatasource>(
      YtDlpProcessDatasource(
        ytDlpPath: ytDlpPath,
        ffmpegPath: ffmpegPath,
        logger: getIt<Logger>(),
      ),
    );
  }

  if (!getIt.isRegistered<DownloadRepository>()) {
    getIt.registerSingleton<DownloadRepository>(
      DownloadRepositoryImpl(datasource: getIt<YtDlpProcessDatasource>()),
    );
  }
}
