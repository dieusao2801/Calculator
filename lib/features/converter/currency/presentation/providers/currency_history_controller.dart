import 'package:calculator/core/log/app_log.dart';
import 'package:calculator/features/history/data/providers/history_repository_providers.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currency_history_controller.g.dart';

/// Notifier quản lý history list cho Currency Converter.
///
/// Save dùng skip-duplicate so với record mới nhất (so sánh code/rate/amount của
/// 4 currency). Insert thật → reload list để UI cập nhật.
@riverpod
class CurrencyHistoryController extends _$CurrencyHistoryController {
  @override
  Future<List<CurrencyConvertHistory>> build() async {
    final repo = ref.read(currencyHistoryRepositoryProvider);
    return repo.getCurrencyConvertHistory();
  }

  /// Insert nếu khác record mới nhất; nếu trùng → no-op.
  Future<void> saveIfNotDuplicate(CurrencyConvertHistory h) async {
    final list = state.value ?? const <CurrencyConvertHistory>[];
    if (list.isNotEmpty && _equals(list.first, h)) return;

    final repo = ref.read(currencyHistoryRepositoryProvider);
    await repo.saveCurrencyHistory(h);
    final updated = await repo.getCurrencyConvertHistory();
    if (!ref.mounted) return;
    AppLog.d('saveIfNotDuplicate: $h');
    state = AsyncData(updated);
  }

  Future<void> deleteById(int id) async {
    final repo = ref.read(currencyHistoryRepositoryProvider);
    await repo.deleteCurrencyHistory(id);
    final updated = await repo.getCurrencyConvertHistory();
    if (!ref.mounted) return;
    state = AsyncData(updated);
  }

  Future<void> clearAll() async {
    final repo = ref.read(currencyHistoryRepositoryProvider);
    await repo.clearAll();
    if (!ref.mounted) return;
    state = const AsyncData([]);
  }

  bool _equals(CurrencyConvertHistory a, CurrencyConvertHistory b) {
    return a.currencyCode1 == b.currencyCode1 &&
        a.exchangeRate1 == b.exchangeRate1 &&
        a.amount1 == b.amount1 &&
        a.currencyCode2 == b.currencyCode2 &&
        a.exchangeRate2 == b.exchangeRate2 &&
        a.amount2 == b.amount2 &&
        a.currencyCode3 == b.currencyCode3 &&
        a.exchangeRate3 == b.exchangeRate3 &&
        a.amount3 == b.amount3 &&
        a.currencyCode4 == b.currencyCode4 &&
        a.exchangeRate4 == b.exchangeRate4 &&
        a.amount4 == b.amount4;
  }
}
