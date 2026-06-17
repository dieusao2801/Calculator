/// Tập trung Base URL + path constants cho toàn bộ network layer.
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL cho Currency Exchange Rate API (proxy nội bộ).
  static const String currencyBaseUrl = 'https://calculator.tohapp.com';

  /// Endpoint lấy tỷ giá; query `param` là Base64 của `date=YYYY-MM-DD` (UTC).
  static const String currencyRates = '/calc.php';
}