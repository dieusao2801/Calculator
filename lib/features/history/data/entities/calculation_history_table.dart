import 'package:drift/drift.dart';

/// Drift Table Definition - Nằm ở tầng Data.
@TableIndex(name: 'idx_calc_history_created_time', columns: {#createdTime})
class CalculationHistoryTable extends Table {
  @override
  String get tableName => 'calc_history';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get expression => text()();
  TextColumn get result => text()();
  BoolColumn get isLock => boolean()();
  TextColumn get note => text()();
  DateTimeColumn get createdTime => dateTime().withDefault(currentDateAndTime)();
}