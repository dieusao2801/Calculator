import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/history/data/mappers/currency_convert_history_mapper.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
import 'package:calculator/features/history/domain/repositories/currency_convert_history_repository.dart';
import 'package:drift/drift.dart';

class CurrencyConvertHistoryRepositoryImpl implements CurrencyConvertHistoryRepository {
  final AppDatabase _db;
  CurrencyConvertHistoryRepositoryImpl(this._db);

  $CurrencyConvertHistoryTableTable get _table => _db.currencyConvertHistoryTable;

  @override
  Future<List<CurrencyConvertHistory>> getCurrencyConvertHistory() async {
    final list = await (_db.select(
      _table,
    )..orderBy([(t) => OrderingTerm.desc(t.createdTime)])).get();
    return list.map((e) => CurrencyConvertHistoryMapper.toDomainModel(e)).toList();
  }

  @override
  Future<void> saveCurrencyHistory(CurrencyConvertHistory data) async {
    await _db.into(_table).insert(CurrencyConvertHistoryMapper.toCompanion(data));
  }

  @override
  Future<void> deleteCurrencyHistory(int id) async {
    await (_db.delete(_table)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_table).go();
  }
}