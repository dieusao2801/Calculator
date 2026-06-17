import 'dart:convert';
import 'package:calculator/core/constants/prefs_keys.dart';
import 'package:calculator/core/prefs/shared_preferences_provider.dart';
import 'package:calculator/core/theme/app_theme_id.dart';
import 'package:calculator/features/converter/currency/data/mappers/currency_convert_history_mapper.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_converter_mode.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
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

  /// Favorite Converters (List of IDs)
  List<String> get favoriteConverters => _prefs.getStringList(PrefsKeys.favoriteConverters) ?? [];

  Future<bool> setFavoriteConverters(List<String> ids) => _prefs.setStringList(PrefsKeys.favoriteConverters, ids);

  /// Currency: timestamp (ms) của response server lần cuối — dùng để chặn ghi đè
  /// data cũ hơn + hiển thị "rate as of ..." trên UI. Default 1656521701000
  /// (2022-06-29) khớp Android: đảm bảo UI luôn có timestamp hợp lý dù chưa fetch.
  static const int defaultCurrencyTimeServer = 1656521701000;

  int get currencyTimeServer => _prefs.getInt(PrefsKeys.currencyTimeServer) ?? defaultCurrencyTimeServer;

  Future<bool> setCurrencyTimeServer(int ms) => _prefs.setInt(PrefsKeys.currencyTimeServer, ms);

  /// Currency: thời điểm device sync rates cuối cùng — dùng cho refresh policy 12h
  DateTime? get currencyTimeUpdate {
    final ms = _prefs.getInt(PrefsKeys.currencyTimeUpdate);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<bool> setCurrencyTimeUpdate(DateTime time) => _prefs.setInt(PrefsKeys.currencyTimeUpdate, time.millisecondsSinceEpoch);

  /// Currency: Converter Mode (Simple/Advanced)
  CurrencyConverterMode get currencyConverterMode =>
      CurrencyConverterMode.fromIndex(_prefs.getInt(PrefsKeys.currencyConverterMode) ?? 0);

  Future<bool> setCurrencyConverterMode(CurrencyConverterMode mode) =>
      _prefs.setInt(PrefsKeys.currencyConverterMode, mode.index);

  CurrencyConvertHistory? get lastCurrencyConvertHistory {
    final json = _prefs.getString(PrefsKeys.lastCurrencyConvertHistory);
    if (json == null || json.isEmpty) return null;
    try {
      return CurrencyConvertHistoryMapper.fromMap(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  Future<bool> setLastCurrencyConvertHistory(CurrencyConvertHistory history) =>
      _prefs.setString(PrefsKeys.lastCurrencyConvertHistory, jsonEncode(CurrencyConvertHistoryMapper.toMap(history)));

  CurrencyConvertHistory? get currencyConvertHistorySimple {
    final json = _prefs.getString(PrefsKeys.currencyConvertHistorySimple);
    if (json == null || json.isEmpty) return null;
    try {
      return CurrencyConvertHistoryMapper.fromMap(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  Future<bool> setCurrencyConvertHistorySimple(CurrencyConvertHistory history) =>
      _prefs.setString(PrefsKeys.currencyConvertHistorySimple, jsonEncode(CurrencyConvertHistoryMapper.toMap(history)));

  Future<bool> clearCurrencyConvertHistorySimple() => _prefs.remove(PrefsKeys.currencyConvertHistorySimple);

  CurrencyConvertHistory? get currencyConvertHistoryAdvance {
    final json = _prefs.getString(PrefsKeys.currencyConvertHistoryAdvance);
    if (json == null || json.isEmpty) return null;
    try {
      return CurrencyConvertHistoryMapper.fromMap(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  Future<bool> setLastCurrencyConvertHistoryAdvance(CurrencyConvertHistory history) =>
      _prefs.setString(PrefsKeys.currencyConvertHistoryAdvance, jsonEncode(CurrencyConvertHistoryMapper.toMap(history)));

  Future<bool> clearCurrencyConvertHistoryAdvance() => _prefs.remove(PrefsKeys.currencyConvertHistoryAdvance);

  /// Currency converter — last record (cặp tiền + input đang gõ dở)
  String? get currencyFromCode => _prefs.getString(PrefsKeys.currencyFromCode);

  Future<bool> setCurrencyFromCode(String code) => _prefs.setString(PrefsKeys.currencyFromCode, code);

  String? get currencyToCode => _prefs.getString(PrefsKeys.currencyToCode);

  Future<bool> setCurrencyToCode(String code) => _prefs.setString(PrefsKeys.currencyToCode, code);

  String? get currencyFromInput => _prefs.getString(PrefsKeys.currencyFromInput);

  Future<bool> setCurrencyFromInput(String value) => _prefs.setString(PrefsKeys.currencyFromInput, value);

  String? get currencyToInput => _prefs.getString(PrefsKeys.currencyToInput);

  Future<bool> setCurrencyToInput(String value) => _prefs.setString(PrefsKeys.currencyToInput, value);

  /// Advanced mode: list 4 codes (lưu cách nhau bằng dấu phẩy để tránh JSON nặng)
  List<String>? get currencyAdvancedCodes {
    final raw = _prefs.getStringList(PrefsKeys.currencyAdvancedCodes);
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  Future<bool> setCurrencyAdvancedCodes(List<String> codes) =>
      _prefs.setStringList(PrefsKeys.currencyAdvancedCodes, codes);

  String? get currencyAdvancedActiveInput => _prefs.getString(PrefsKeys.currencyAdvancedActiveInput);

  Future<bool> setCurrencyAdvancedActiveInput(String value) =>
      _prefs.setString(PrefsKeys.currencyAdvancedActiveInput, value);

  int? get currencyFocusedSimple => _prefs.getInt(PrefsKeys.currencyFocusedSimple);

  Future<bool> setCurrencyFocusedSimple(int index) =>
      _prefs.setInt(PrefsKeys.currencyFocusedSimple, index);

  int? get currencyFocusedAdvanced => _prefs.getInt(PrefsKeys.currencyFocusedAdvanced);

  Future<bool> setCurrencyFocusedAdvanced(int index) =>
      _prefs.setInt(PrefsKeys.currencyFocusedAdvanced, index);
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
