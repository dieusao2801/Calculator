import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/history/domain/entities/time_zone_alternative.dart';
import 'package:drift/drift.dart';

class TimeZoneAlternativeMapper {
  static TimeZoneAlternative toDomainModel(TimeZoneAlternativeTableData data) {
    return TimeZoneAlternative(
      id: data.id,
      oldTimeZone: data.oldTimeZone,
      newTimeZone: data.newTimeZone,
      rootCity: data.rootCity,
    );
  }

  static TimeZoneAlternativeTableCompanion toCompanion(TimeZoneAlternative data) {
    return TimeZoneAlternativeTableCompanion(
      id: data.id != null ? Value(data.id!) : const Value.absent(),
      oldTimeZone: Value(data.oldTimeZone),
      newTimeZone: Value(data.newTimeZone),
      rootCity: Value(data.rootCity),
    );
  }
}