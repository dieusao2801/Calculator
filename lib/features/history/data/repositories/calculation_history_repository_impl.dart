import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/history/data/mappers/calculation_history_mapper.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:calculator/features/history/domain/repositories/calculation_history_repository.dart';
import 'package:drift/drift.dart';

class CalculationHistoryRepositoryImpl implements CalculationHistoryRepository {
  final AppDatabase _db;
  CalculationHistoryRepositoryImpl(this._db);

  $CalculationHistoryTableTable get _table => _db.calculationHistoryTable;

  @override
  Future<List<CalculationHistory>> getAllHistory() async {
    final list = await (_db.select(
      _table,
    )..orderBy([(t) => OrderingTerm.desc(t.createdTime)])).get();
    return list.map((e) => CalculationHistoryMapper.toDomainModel(e)).toList();
  }

  @override
  Future<void> saveHistory(CalculationHistory entity) async {
    await _db.into(_table).insert(CalculationHistoryMapper.toCompanion(entity));
  }

  @override
  Future<void> deleteHistory(int id) async {
    await (_db.delete(_table)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete(_table).go();
  }
}