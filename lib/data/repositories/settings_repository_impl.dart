import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_datasource.dart';

/// Concrete [SettingsRepository] backed by [SettingsLocalDatasource].
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required SettingsLocalDatasource datasource})
      : _datasource = datasource;

  final SettingsLocalDatasource _datasource;

  @override
  Future<AppSettings> loadSettings() => _datasource.loadSettings();

  @override
  Future<void> saveSettings(AppSettings settings) => _datasource.saveSettings(settings);

  @override
  Future<void> resetSettings() => _datasource.resetSettings();
}
