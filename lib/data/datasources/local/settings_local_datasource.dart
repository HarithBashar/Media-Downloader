import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/app_settings.dart';

/// SharedPreferences-based datasource for application settings.
class SettingsLocalDatasource {
  SettingsLocalDatasource({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  Future<AppSettings> loadSettings() async {
    try {
      final jsonStr = _prefs.getString(AppConstants.keySettings);
      if (jsonStr == null) return const AppSettings();
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (e) {
      // Return defaults on parse failure
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      final jsonStr = json.encode(settings.toJson());
      await _prefs.setString(AppConstants.keySettings, jsonStr);
    } catch (e) {
      throw StorageException('Failed to save settings.', cause: e);
    }
  }

  Future<void> resetSettings() async {
    await _prefs.remove(AppConstants.keySettings);
  }
}
