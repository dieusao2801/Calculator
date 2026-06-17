import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';

abstract class CurrencyRepository {
  /// Lấy toàn bộ list currency từ DB local.
  Future<List<CurrencyRate>> getAll();

  /// Seed DB từ const list `CurrencyDefinition` nếu DB rỗng.
  /// Idempotent — gọi lại không có side effect khi đã có data.
  Future<void> initialData();

  /// `true` nếu lần update cuối đã vượt refresh threshold (12h) hoặc chưa từng update.
  bool isStale();

  /// Fetch server nếu lần update cuối đã quá refresh threshold (12h).
  /// Trả `true` nếu fetch thành công hoặc chưa cần refresh.
  Future<bool> refreshIfStale();

  /// Ép buộc fetch server bất kể threshold (cho pull-to-refresh sau này).
  Future<bool> refreshFromServer();
}
