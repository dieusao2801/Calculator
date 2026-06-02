import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';

abstract class CurrencyConvertHistoryRepository {
  Future<List<CurrencyConvertHistory>> getCurrencyConvertHistory();

  Future<void> saveCurrencyHistory(CurrencyConvertHistory data);

  Future<void> deleteCurrencyHistory(int id);

  Future<void> clearAll();
}