import 'package:drift/drift.dart';

/// Drift Table Definition - Nằm ở tầng Data.
@TableIndex(name: 'idx_currency_history_created_time', columns: {#createdTime})
class CurrencyConvertHistoryTable extends Table {
  @override
  String get tableName => 'currency_convert_history';

  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get ratesLastUpdated => dateTime().withDefault(
    currentDateAndTime,
  )(); //Thời điểm tỷ giá được cập nhật lần cuối từ server.

  TextColumn get currencyCode1 => text()(); // Mã tiền tệ thứ 1 (Ví dụ: USD).
  TextColumn get exchangeRate1 => text()(); // Tỷ giá hối đoái thứ 1.
  TextColumn get amount1 => text()(); // Số tiền/Giá trị của tiền tệ thứ 1.

  TextColumn get currencyCode2 => text()(); // Mã tiền tệ thứ 2.
  TextColumn get exchangeRate2 => text()(); // Tỷ giá hối đoái thứ 2.
  TextColumn get amount2 => text()(); // Số tiền/Giá trị của tiền tệ thứ 2.

  TextColumn get currencyCode3 => text().nullable()(); // Mã tiền tệ thứ 3.
  TextColumn get exchangeRate3 => text().nullable()(); // Tỷ giá hối đoái thứ 3.
  TextColumn get amount3 => text().nullable()(); // Số tiền/Giá trị của tiền tệ thứ 3.

  TextColumn get currencyCode4 => text().nullable()(); // Mã tiền tệ thứ 4.
  TextColumn get exchangeRate4 => text().nullable()(); // Tỷ giá hối đoái thứ 4.
  TextColumn get amount4 => text().nullable()(); // Số tiền/Giá trị của tiền tệ thứ 4.
  DateTimeColumn get createdTime => dateTime().withDefault(currentDateAndTime)();
}