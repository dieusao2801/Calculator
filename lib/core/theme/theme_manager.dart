import 'package:calculator/core/theme/app_theme_id.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_manager.g.dart';

const String _prefsKeyThemeId = 'app_theme_id';

/*
  Chức năng: Cung cấp instance [SharedPreferences] đã warm-up cho cây Riverpod.
  Throw UnimplementedError nếu chưa override — buộc caller phải warm-up trước
  để theme load đồng bộ ở frame đầu (tránh flicker).
  Gọi tại: `main.dart` — `ProviderScope.overrides` truyền instance đã warm-up.
*/
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('Phải override sharedPreferencesProvider trong main.dart');
}

/// Quản lý state theme đang chọn — Riverpod notifier persist xuống
/// [SharedPreferences]. UI gọi [setTheme] để đổi; `MyApp` watch để rebuild
/// MaterialApp với theme mới.
@Riverpod(keepAlive: true)
class ThemeManager extends _$ThemeManager {
  /*
    Chức năng: Load theme đã persist khi notifier khởi tạo lần đầu — fallback
    `classic` nếu chưa có hoặc raw không hợp lệ.
    Gọi tại: Riverpod tự động khi `ref.watch(themeManagerProvider)` đầu tiên.
  */
  @override
  AppThemeId build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppThemeId.fromStorage(prefs.getString(_prefsKeyThemeId));
  }

  /*
    Chức năng: Đổi theme đang chọn và persist xuống SharedPreferences. Early
    return nếu trùng với state hiện tại để tránh rebuild thừa.
    Gọi tại: `theme_selector_section.dart` — khi user tap chọn theme khác.
  */
  Future<void> setTheme(AppThemeId id) async {
    if (state == id) return;
    state = id;
    await ref.read(sharedPreferencesProvider).setString(_prefsKeyThemeId, id.name);
  }
}