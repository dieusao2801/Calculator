import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/core/log/app_log.dart';
import 'package:calculator/features/converter/currency/data/currency_definitions.dart';
import 'package:calculator/features/converter/currency/data/mappers/currency_rate_mapper.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';
import 'package:drift/drift.dart';

class CurrencyLocalDataSource {
  CurrencyLocalDataSource(this._db);

  final AppDatabase _db;

  $CurrencyRateTableTable get _table => _db.currencyRateTable;

  Future<List<CurrencyRate>> getAll() async {
    final list = await _db.select(_table).get();
    return list.map(CurrencyRateMapper.toDomain).toList();
  }

  Future<int> _count() async {
    final row = await _db.customSelect('SELECT COUNT(*) AS c FROM ${_table.actualTableName}', readsFrom: {_table}).getSingle();
    return row.read<int>('c');
  }

  /// Khởi tạo dữ liệu currency khi DB trống. Idempotent — gọi lại khi đã có
  /// data sẽ no-op. Khớp logic Android `importData()`.
  Future<void> initialData() async {
    final isEmpty = await _count() == 0;
    AppLog.d('CurrencyLocalDataSource: initialData — isEmpty=$isEmpty');
    if (!isEmpty) return;

    final supported = getSupportedCurrencies();
    await _db.batch((batch) {
      batch.insertAll(_table, [
        for (final c in supported)
          CurrencyRateTableCompanion.insert(code: c.code, name: c.name, rate: Value(c.rate)),
      ]);
    });
    AppLog.d('CurrencyLocalDataSource: seeded ${supported.length} currencies');
  }

  /// Bulk update rate + updatedAt cho các code đã có trong DB.
  Future<void> upsertRates(Map<String, double> rateByCode, DateTime updatedAt) async {
    await _db.batch((batch) {
      for (final entry in rateByCode.entries) {
        batch.update(
          _table,
          CurrencyRateTableCompanion(rate: Value(entry.value), updatedAt: Value(updatedAt)),
          where: (t) => t.code.equals(entry.key),
        );
      }
    });
  }
}
