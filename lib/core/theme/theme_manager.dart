import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/core/theme/app_theme_id.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_manager.g.dart';

/// Quản lý state theme đang chọn — Riverpod notifier persist qua
/// [AppPrefs]. UI gọi [setTheme] để đổi; `MyApp` watch để rebuild
/// MaterialApp với theme mới.
@Riverpod(keepAlive: true)
class ThemeManager extends _$ThemeManager {
  /*
    Chức năng: Load theme đã persist khi notifier khởi tạo lần đầu — prefs
    tự fallback `classic` nếu chưa có hoặc raw không hợp lệ.
    Gọi tại: Riverpod tự động khi `ref.watch(themeManagerProvider)` đầu tiên.
  */
  @override
  AppThemeId build() {
    return ref.watch(appPrefsProvider).themeId;
  }

  /*
    Chức năng: Đổi theme đang chọn và persist. Early return nếu trùng với
    state hiện tại để tránh rebuild thừa.
    Gọi tại: `theme_selector_section.dart` — khi user tap chọn theme khác.
  */
  Future<void> setTheme(AppThemeId id) async {
    if (state == id) return;
    state = id;
    await ref.read(appPrefsProvider).setThemeId(id);
  }
}