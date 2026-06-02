import 'package:drift/drift.dart';

@TableIndex(name: 'idx_percentage_history_created_time', columns: {#createdTime})
class PercentageHistoryTable extends Table {
  @override
  String get tableName => 'percentage_history';

  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdTime => dateTime().withDefault(currentDateAndTime)();
  TextColumn get initialValue => text().nullable()();
  TextColumn get percentValue => text().nullable()();
  TextColumn get changeValue => text().nullable()();
  TextColumn get finalValue => text().nullable()();
  IntColumn get changedPosition1 => integer().nullable()();
  IntColumn get changedPosition2 => integer().nullable()();
}