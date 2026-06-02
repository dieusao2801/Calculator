import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/history/data/mappers/percentage_history_mapper.dart';
import 'package:calculator/features/history/domain/entities/percentage_history.dart';
import 'package:calculator/features/history/domain/repositories/percentage_history_repository.dart';
import 'package:drift/drift.dart';

class PercentageHistoryRepositoryImpl implements PercentageHistoryRepository {
  final AppDatabase _db;
  PercentageHistoryRepositoryImpl(this._db);

  $PercentageHistoryTableTable get _table => _db.percentageHistoryTable;

  @override
  Future<List<PercentageHistory>> getPercentageHistory() async {
    final list = await (_db.select(
      _table,
    )..orderBy([(t) => OrderingTerm.desc(t.createdTime)])).get();
    return list.map((e) => PercentageHistoryMapper.toDomainModel(e)).toList();
  }

  @override
  Future<void> savePercentageHistory(PercentageHistory data) async {
    await _db.into(_table).insert(PercentageHistoryMapper.toCompanion(data));
  }

  @override
  Future<void> deletePercentageHistory(int id) async {
    await (_db.delete(_table)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_table).go();
  }
}