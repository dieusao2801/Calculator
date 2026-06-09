import 'package:calculator/core/helpers/audio_helper.dart';
import 'package:calculator/core/helpers/vibration_helper.dart';
import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/settings/domain/settings_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

/// Quản lý cấu hình tap-feedback (sound + vibration). Persist qua
/// [AppPrefs] và sync ngay vào [AudioHelper.enabled] /
/// [VibrationHelper.enabled] để có hiệu lực tức thì toàn app.
@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() {
    final prefs = ref.watch(appPrefsProvider);
    final state = SettingsState(
      soundEnabled: prefs.soundEnabled,
      vibrationEnabled: prefs.vibrationEnabled,
    );
    _syncHelpers(state);
    return state;
  }

  Future<void> setSoundEnabled(bool value) async {
    if (state.soundEnabled == value) return;
    state = state.copyWith(soundEnabled: value);
    AudioHelper.enabled = value;
    await ref.read(appPrefsProvider).setSoundEnabled(value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    if (state.vibrationEnabled == value) return;
    state = state.copyWith(vibrationEnabled: value);
    VibrationHelper.enabled = value;
    await ref.read(appPrefsProvider).setVibrationEnabled(value);
  }

  void _syncHelpers(SettingsState s) {
    AudioHelper.enabled = s.soundEnabled;
    VibrationHelper.enabled = s.vibrationEnabled;
  }
}
