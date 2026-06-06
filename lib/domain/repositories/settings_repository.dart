import '../entities/app_settings.dart';

/// Abstract repository contract for application settings.
abstract interface class SettingsRepository {
  /// Loads settings from persistent storage. Returns defaults if not found.
  Future<AppSettings> loadSettings();

  /// Persists [settings] to storage.
  Future<void> saveSettings(AppSettings settings);

  /// Resets all settings to their default values.
  Future<void> resetSettings();
}
