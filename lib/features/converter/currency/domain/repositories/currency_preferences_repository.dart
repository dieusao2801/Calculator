import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
import '../entities/currency_converter_mode.dart';

abstract class CurrencyPreferencesRepository {
  Future<CurrencyConverterMode> getMode();
  Future<void> saveMode(CurrencyConverterMode mode);

  Future<CurrencyConvertHistory?> getSimpleHistory();
  Future<void> saveSimpleHistory(CurrencyConvertHistory history);

  Future<CurrencyConvertHistory?> getAdvanceHistory();
  Future<void> saveAdvanceHistory(CurrencyConvertHistory history);
}
