import 'package:drift/drift.dart';

class TimeZoneAlternativeTable extends Table {
  @override
  String get tableName => 'tb_time_zone_alternative';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get oldTimeZone => text().withDefault(const Constant(""))();
  TextColumn get newTimeZone => text().withDefault(const Constant(""))();
  TextColumn get rootCity => text().withDefault(const Constant(""))();
}