import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
import 'package:drift/drift.dart';

/// Mapper chuyển đổi giữa Entity (Domain) và Data/Companion (Data Layer)
/// cho lịch sử quy đổi tiền tệ.
class CurrencyConvertHistoryMapper {
  static CurrencyConvertHistory toDomainModel(CurrencyConvertHistoryTableData data) {
    return CurrencyConvertHistory(
      id: data.id,
      ratesLastUpdated: data.ratesLastUpdated,
      currencyCode1: data.currencyCode1,
      exchangeRate1: data.exchangeRate1,
      amount1: data.amount1,
      currencyCode2: data.currencyCode2,
      exchangeRate2: data.exchangeRate2,
      amount2: data.amount2,
      currencyCode3: data.currencyCode3,
      exchangeRate3: data.exchangeRate3,
      amount3: data.amount3,
      currencyCode4: data.currencyCode4,
      exchangeRate4: data.exchangeRate4,
      amount4: data.amount4,
      createdTime: data.createdTime,
    );
  }

  static CurrencyConvertHistoryTableCompanion toCompanion(CurrencyConvertHistory data) {
    return CurrencyConvertHistoryTableCompanion(
      id: data.id != null ? Value(data.id!) : const Value.absent(),
      ratesLastUpdated: Value(data.ratesLastUpdated),
      currencyCode1: Value(data.currencyCode1),
      exchangeRate1: Value(data.exchangeRate1),
      amount1: Value(data.amount1),
      currencyCode2: Value(data.currencyCode2),
      exchangeRate2: Value(data.exchangeRate2),
      amount2: Value(data.amount2),
      currencyCode3: Value(data.currencyCode3),
      exchangeRate3: Value(data.exchangeRate3),
      amount3: Value(data.amount3),
      currencyCode4: Value(data.currencyCode4),
      exchangeRate4: Value(data.exchangeRate4),
      amount4: Value(data.amount4),
      createdTime: Value(data.createdTime),
    );
  }
}