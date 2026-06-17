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

  static CurrencyConvertHistory fromMap(Map<String, dynamic> map) {
    return CurrencyConvertHistory(
      id: map['id'] as int?,
      ratesLastUpdated: DateTime.parse(map['ratesLastUpdated'] as String),
      currencyCode1: map['currencyCode1'] as String,
      exchangeRate1: map['exchangeRate1'] as String,
      amount1: map['amount1'] as String,
      currencyCode2: map['currencyCode2'] as String,
      exchangeRate2: map['exchangeRate2'] as String,
      amount2: map['amount2'] as String,
      currencyCode3: map['currencyCode3'] as String?,
      exchangeRate3: map['exchangeRate3'] as String?,
      amount3: map['amount3'] as String?,
      currencyCode4: map['currencyCode4'] as String?,
      exchangeRate4: map['exchangeRate4'] as String?,
      amount4: map['amount4'] as String?,
      createdTime: DateTime.parse(map['createdTime'] as String),
    );
  }

  static Map<String, dynamic> toMap(CurrencyConvertHistory entity) {
    return {
      'id': entity.id,
      'ratesLastUpdated': entity.ratesLastUpdated.toIso8601String(),
      'currencyCode1': entity.currencyCode1,
      'exchangeRate1': entity.exchangeRate1,
      'amount1': entity.amount1,
      'currencyCode2': entity.currencyCode2,
      'exchangeRate2': entity.exchangeRate2,
      'amount2': entity.amount2,
      'currencyCode3': entity.currencyCode3,
      'exchangeRate3': entity.exchangeRate3,
      'amount3': entity.amount3,
      'currencyCode4': entity.currencyCode4,
      'exchangeRate4': entity.exchangeRate4,
      'amount4': entity.amount4,
      'createdTime': entity.createdTime.toIso8601String(),
    };
  }
}
