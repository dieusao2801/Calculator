/// 4 tab chính ở màn Home, theo đúng thứ tự hiển thị trên MenuTabs.
///
/// Đặt ở `core/router/` (không phải `features/home/`) vì là concept navigation,
/// được `NavigationController` ở core dùng — tránh cross-feature import ngược.
enum HomeTab {
  recent,
  converter,
  calculator,
  settings;

  /// Parse từ index (vd PageView onPageChanged trả int).
  /// Dart enum đã có sẵn property `.index` (kế thừa từ Enum) — dùng trực tiếp.
  static HomeTab fromIndex(int index) {
    if (index < 0 || index >= HomeTab.values.length) {
      return HomeTab.calculator;
    }
    return HomeTab.values[index];
  }
}
