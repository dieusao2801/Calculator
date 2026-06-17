import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_converter_mode.dart';
import 'package:calculator/features/converter/currency/domain/repositories/currency_preferences_repository.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';

class CurrencyPreferencesRepositoryImpl implements CurrencyPreferencesRepository {
  CurrencyPreferencesRepositoryImpl(this._prefs);

  final AppPrefs _prefs;

  @override
  Future<CurrencyConverterMode> getMode() async => _prefs.currencyConverterMode;

  @override
  Future<void> saveMode(CurrencyConverterMode mode) => _prefs.setCurrencyConverterMode(mode);

  @override
  Future<CurrencyConvertHistory?> getSimpleHistory() async => _prefs.currencyConvertHistorySimple;

  @override
  Future<void> saveSimpleHistory(CurrencyConvertHistory history) => _prefs.setCurrencyConvertHistorySimple(history);

  @override
  Future<CurrencyConvertHistory?> getAdvanceHistory() async => _prefs.currencyConvertHistoryAdvance;

  @override
  Future<void> saveAdvanceHistory(CurrencyConvertHistory history) => _prefs.setLastCurrencyConvertHistoryAdvance(history);
}
