import 'package:drift/drift.dart';

/// Drift Table — lưu currency code + tên theo locale + tỷ giá hiện tại.
@TableIndex(name: 'idx_currency_rate_updated_at', columns: {#updatedAt})
class CurrencyRateTable extends Table {
  @override
  String get tableName => 'currency_rate';

  TextColumn get code => text()(); // PK — vd USD, EUR
  TextColumn get name => text()(); // Tên hiển thị theo locale
  RealColumn get rate => real().nullable()(); // 1 / quote (USD per 1 unit)
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {code};
}