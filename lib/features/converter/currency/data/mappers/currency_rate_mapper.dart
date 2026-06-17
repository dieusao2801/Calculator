import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';
import 'package:drift/drift.dart';

class CurrencyRateMapper {
  static CurrencyRate toDomain(CurrencyRateTableData data) {
    return CurrencyRate(code: data.code, name: data.name, rate: data.rate, updatedAt: data.updatedAt);
  }

  static CurrencyRateTableCompanion toCompanion(CurrencyRate entity) {
    return CurrencyRateTableCompanion(
      code: Value(entity.code),
      name: Value(entity.name),
      rate: Value(entity.rate),
      updatedAt: Value(entity.updatedAt),
    );
  }
}