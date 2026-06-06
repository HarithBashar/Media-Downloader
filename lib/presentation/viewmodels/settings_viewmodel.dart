import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// ViewModel for the settings screen. Loads, updates, and persists [AppSettings].
class SettingsViewModel extends AsyncNotifier<AppSettings> {
  late SettingsRepository _repo;

  @override
  Future<AppSettings> build() async {
    _repo = getIt<SettingsRepository>();
    return await _repo.loadSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = const AsyncLoading();
    try {
      await _repo.saveSettings(settings);
      state = AsyncData(settings);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> updateField(AppSettings Function(AppSettings) updater) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await updateSettings(updater(current));
  }

  Future<void> resetToDefaults() async {
    try {
      await _repo.resetSettings();
      state = const AsyncData(AppSettings());
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsViewModel, AppSettings>(
  SettingsViewModel.new,
);
