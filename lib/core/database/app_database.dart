import 'package:calculator/features/history/data/entities/calculation_history_table.dart';
import 'package:calculator/features/history/data/entities/currency_convert_history_table.dart';
import 'package:calculator/features/history/data/entities/time_zone_alternative_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/history/data/entities/percentage_history_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CalculationHistoryTable, CurrencyConvertHistoryTable, PercentageHistoryTable, TimeZoneAlternativeTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'calculator_db');
  }
}
