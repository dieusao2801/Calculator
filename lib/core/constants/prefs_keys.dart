/// Tập trung tất cả key dùng cho [SharedPreferences].
///
/// Quy tắc:
/// - Giá trị string đã persist trên thiết bị user — KHÔNG đổi value của key
///   đã ship, chỉ rename biến tham chiếu. Đổi value sẽ làm mất data cũ.
/// - Thêm key mới: đặt cùng nhóm theo comment phân vùng; khi vượt ~8 key sẽ
///   tách thành nested class theo feature.
class PrefsKeys {
  PrefsKeys._();

  // Theme
  static const String themeId = 'app_theme_id';

  // Settings — tap feedback
  static const String soundEnabled = 'settings_sound_enabled';
  static const String vibrationEnabled = 'settings_vibration_enabled';
  static const String lastFormula = 'last_formula';
}
