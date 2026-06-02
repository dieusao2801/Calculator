import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/history/data/mappers/time_zone_alternative_mapper.dart';
import 'package:calculator/features/history/domain/entities/time_zone_alternative.dart';
import 'package:calculator/features/history/domain/repositories/time_zone_alternative_repository.dart';
import 'package:drift/drift.dart';

class TimeZoneAlternativeRepositoryImpl implements TimeZoneAlternativeRepository {
  final AppDatabase _db;
  TimeZoneAlternativeRepositoryImpl(this._db);

  $TimeZoneAlternativeTableTable get _table => _db.timeZoneAlternativeTable;

  @override
  Future<List<TimeZoneAlternative>> getAllTimeZoneAlternatives() async {
    final list = await _db.select(_table).get();
    return list.map((e) => TimeZoneAlternativeMapper.toDomainModel(e)).toList();
  }

  @override
  Future<void> saveTimeZoneAlternative(TimeZoneAlternative data) async {
    await _db
        .into(_table)
        .insert(TimeZoneAlternativeMapper.toCompanion(data), mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> deleteTimeZoneAlternative(int id) async {
    await (_db.delete(_table)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_table).go();
  }
}