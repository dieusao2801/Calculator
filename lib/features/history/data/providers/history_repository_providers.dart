import 'package:calculator/core/database/database_provider.dart';
import 'package:calculator/features/history/data/repositories/calculation_history_repository_impl.dart';
import 'package:calculator/features/history/data/repositories/currency_convert_history_repository_impl.dart';
import 'package:calculator/features/history/data/repositories/percentage_history_repository_impl.dart';
import 'package:calculator/features/history/data/repositories/time_zone_alternative_repository_impl.dart';
import 'package:calculator/features/history/domain/repositories/calculation_history_repository.dart';
import 'package:calculator/features/history/domain/repositories/currency_convert_history_repository.dart';
import 'package:calculator/features/history/domain/repositories/percentage_history_repository.dart';
import 'package:calculator/features/history/domain/repositories/time_zone_alternative_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_repository_providers.g.dart';

@Riverpod(keepAlive: true)
CalculationHistoryRepository historyRepository(Ref ref) {
  return CalculationHistoryRepositoryImpl(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
CurrencyConvertHistoryRepository currencyHistoryRepository(Ref ref) {
  return CurrencyConvertHistoryRepositoryImpl(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
PercentageHistoryRepository percentageHistoryRepository(Ref ref) {
  return PercentageHistoryRepositoryImpl(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
TimeZoneAlternativeRepository timeZoneRepository(Ref ref) {
  return TimeZoneAlternativeRepositoryImpl(ref.watch(appDatabaseProvider));
}
