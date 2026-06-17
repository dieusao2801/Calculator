import 'package:calculator/core/database/database_provider.dart';
import 'package:calculator/core/network/dio_provider.dart';
import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/converter/currency/data/api/currency_api.dart';
import 'package:calculator/features/converter/currency/data/datasources/currency_local_datasource.dart';
import 'package:calculator/features/converter/currency/data/datasources/currency_remote_datasource.dart';
import 'package:calculator/features/converter/currency/data/repositories/currency_repository_impl.dart';
import 'package:calculator/features/converter/currency/domain/repositories/currency_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currency_repository_providers.g.dart';

@Riverpod(keepAlive: true)
CurrencyApi currencyApi(Ref ref) => CurrencyApi(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
CurrencyRemoteDataSource currencyRemoteDataSource(Ref ref) =>
    CurrencyRemoteDataSource(ref.watch(currencyApiProvider));

@Riverpod(keepAlive: true)
CurrencyLocalDataSource currencyLocalDataSource(Ref ref) =>
    CurrencyLocalDataSource(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
CurrencyRepository currencyRepository(Ref ref) => CurrencyRepositoryImpl(
  ref.watch(currencyRemoteDataSourceProvider),
  ref.watch(currencyLocalDataSourceProvider),
  ref.watch(appPrefsProvider),
);

/// Future dedup khởi tạo currency data (seed DB + backfill).
/// Chạy đúng 1 lần trong vòng đời app (keepAlive). Consumer `await` Future này:
/// - Chưa kick off → trigger ngay.
/// - Đang chạy → đợi cùng Future.
/// - Đã xong → resolve ngay.
@Riverpod(keepAlive: true)
Future<void> currencyInitializer(Ref ref) async {
  final repo = ref.watch(currencyRepositoryProvider);
  await repo.initialData();
}