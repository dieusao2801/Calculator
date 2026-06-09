import 'package:calculator/core/constants/prefs_keys.dart';
import 'package:calculator/core/prefs/shared_preferences_provider.dart';
import 'package:calculator/core/theme/app_theme_id.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_prefs.g.dart';

/// Gom mọi accessor [SharedPreferences] vào 1 nơi — caller không cần biết key
/// hay primitive type. Getter trả default value khi key chưa có; setter giữ
/// kiểu [Future] để caller có thể await đảm bảo persist xong trước khi điều
/// hướng / rebuild state.
///
/// Quy ước thêm key mới:
/// - Khai báo `PrefsKeys.X` trước, rồi viết cặp `get X` + `setX(value)` ở đây.
/// - Mọi conversion enum/JSON nằm trong helper, không leak ra caller.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  /// Theme
  AppThemeId get themeId => AppThemeId.fromStorage(_prefs.getString(PrefsKeys.themeId));
  Future<bool> setThemeId(AppThemeId id) => _prefs.setString(PrefsKeys.themeId, id.name);

  /// Settings — tap feedback
  bool get soundEnabled => _prefs.getBool(PrefsKeys.soundEnabled) ?? false;
  Future<bool> setSoundEnabled(bool value) => _prefs.setBool(PrefsKeys.soundEnabled, value);

  /// Vibration when tap feedback
  bool get vibrationEnabled => _prefs.getBool(PrefsKeys.vibrationEnabled) ?? false;
  Future<bool> setVibrationEnabled(bool value) => _prefs.setBool(PrefsKeys.vibrationEnabled, value);

  /// Last formula
  String get lastFormula => _prefs.getString(PrefsKeys.lastFormula) ?? '';
  Future<bool> setLastFormula(String value) => _prefs.setString(PrefsKeys.lastFormula, value);
}

/*
  Chức năng: Cung cấp [AppPrefs] đã gắn với instance prefs warm-up.
  keepAlive để giữ singleton suốt vòng đời app, tránh tạo lại mỗi lần watch.
  Gọi tại: mọi controller cần đọc/ghi prefs (theme_manager, settings_controller…).
*/
@Riverpod(keepAlive: true)
AppPrefs appPrefs(Ref ref) {
  return AppPrefs(ref.watch(sharedPreferencesProvider));
}
