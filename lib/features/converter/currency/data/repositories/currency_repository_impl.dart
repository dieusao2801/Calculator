import 'package:calculator/core/log/app_log.dart';
import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/converter/currency/data/datasources/currency_local_datasource.dart';
import 'package:calculator/features/converter/currency/data/datasources/currency_remote_datasource.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';
import 'package:calculator/features/converter/currency/domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  CurrencyRepositoryImpl(this._remote, this._local, this._prefs);

  final CurrencyRemoteDataSource _remote;
  final CurrencyLocalDataSource _local;
  final AppPrefs _prefs;

  /// Refresh threshold — fetch lại nếu device đã sync cách đây >= 4h (khớp app gốc).
  static const Duration _kRefreshThreshold = Duration(hours: 4);

  @override
  Future<List<CurrencyRate>> getAll() => _local.getAll();

  @override
  Future<void> initialData() => _local.initialData();

  @override
  bool isStale() {
    final lastUpdate = _prefs.currencyTimeUpdate;
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) >= _kRefreshThreshold;
  }

  @override
  Future<bool> refreshIfStale() async {
    if (!isStale()) return true; // chưa cần fetch
    return refreshFromServer();
  }

  @override
  Future<bool> refreshFromServer() async {
    try {
      final dto = await _remote.getExchangeRates();
      if (!dto.success) {
        AppLog.e('refreshFromServer: server trả success=false');
        return false;
      }

      // Chỉ update khi server fresh hơn cache; nếu server cũ hơn thì bỏ qua hoàn
      // toàn (khớp Android: không chạm `currencyTimeUpdate` để lần fetch sau vẫn
      // được phép thử lại). Request success thì luôn trả `true`.
      final serverTimeMs = dto.timestamp * 1000;
      final savedTimeMs = _prefs.currencyTimeServer;
      if (serverTimeMs >= savedTimeMs) {
        // Map code → 1/quote; VEF tra cứu USDVES theo logic Android
        final currencies = await _local.getAll();
        final Map<String, double> rateMap = {};
        for (final c in currencies) {
          final key = c.code == 'VEF' ? 'USDVES' : 'USD${c.code}';
          final quote = dto.quotes[key];
          if (quote != null && quote != 0) {
            rateMap[c.code] = 1.0 / quote;
          }
        }

        await _local.upsertRates(rateMap, DateTime.fromMillisecondsSinceEpoch(serverTimeMs));
        await _prefs.setCurrencyTimeServer(serverTimeMs);
        await _prefs.setCurrencyTimeUpdate(DateTime.now());
        AppLog.d('refreshFromServer: updated ${rateMap.length} rates, serverTime=$serverTimeMs');
      } else {
        AppLog.d('refreshFromServer: server stale (serverTime=$serverTimeMs < saved=$savedTimeMs), skip update');
      }
      return true;
    } catch (e, st) {
      AppLog.e('refreshFromServer: $e', e, st);
      return false;
    }
  }
}
