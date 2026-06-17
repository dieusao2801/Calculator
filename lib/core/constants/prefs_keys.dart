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

  // Converter
  static const String favoriteConverters = 'converter_favorites';

  // Currency rate sync
  static const String currencyTimeServer = 'currency_time_server';
  static const String currencyTimeUpdate = 'currency_time_update';
  static const String lastCurrencyConvertHistory = 'last_currency_convert_history';
  static const String currencyConverterMode = 'currency_converter_mode';
  static const String currencyConvertHistorySimple = 'currency_convert_history_simple';
  static const String currencyConvertHistoryAdvance = 'currency_convert_history_advance';

  // Currency converter — input/pair state (persist last record)
  static const String currencyFromCode = 'currency_from_code';
  static const String currencyToCode = 'currency_to_code';
  static const String currencyFromInput = 'currency_from_input';
  static const String currencyToInput = 'currency_to_input';
  static const String currencyAdvancedCodes = 'currency_advanced_codes';
  static const String currencyAdvancedActiveInput = 'currency_advanced_active_input';
  static const String currencyFocusedSimple = 'currency_focused_simple';
  static const String currencyFocusedAdvanced = 'currency_focused_advanced';
}
