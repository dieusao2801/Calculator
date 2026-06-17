import 'package:calculator/core/helpers/connectivity_helper.dart';
import 'package:calculator/core/log/app_log.dart';
import 'package:calculator/features/converter/currency/data/providers/currency_repository_providers.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currency_rates_controller.g.dart';

@riverpod
class CurrencyRatesController extends _$CurrencyRatesController {
  bool _isFetching = false;

  @override
  Future<List<CurrencyRate>> build() async {
    // Đợi initializer hoàn tất (kick off lazy nếu splash chưa trigger).
    await ref.watch(currencyInitializerProvider.future);
    final repo = ref.read(currencyRepositoryProvider);
    return repo.getAll();
  }

  /// Quyết định có cần refresh khi user vào page / resume app hay không.
  /// Skip khi: đang fetch / cache còn fresh / offline.
  Future<bool> shouldRefreshOnEnter() async {
    if (_isFetching) {
      AppLog.d('CurrencyRatesController: skip — đang fetch');
      return false;
    }
    final repo = ref.read(currencyRepositoryProvider);
    if (!repo.isStale()) {
      AppLog.d('CurrencyRatesController: skip — cache còn fresh (< 4h)');
      return false;
    }
    final hasInternet = await ConnectivityHelper.isConnected;
    if (!hasInternet) {
      AppLog.d('CurrencyRatesController: skip — không có internet');
      return false;
    }
    return true;
  }

  /// Force refresh — fetch tỷ giá mới và cập nhật state.
  /// Trả `true` nếu fetch thành công.
  Future<bool> refresh() async {
    if (_isFetching) return false;
    _isFetching = true;
    try {
      final repo = ref.read(currencyRepositoryProvider);
      AppLog.d('CurrencyRatesController: bắt đầu refresh exchange rate');
      final ok = await repo.refreshFromServer();
      AppLog.d('CurrencyRatesController: refresh xong, ok=$ok');
      if (!ok) return false;
      final updated = await repo.getAll();
      if (!ref.mounted) return true;
      state = AsyncData(updated);
      return true;
    } finally {
      _isFetching = false;
    }
  }
}
