import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';

/// Giá trị tối đa của kết quả convert — khớp Android `MAX_VALUE_CONVERT = 1E+25`.
/// Vượt ngưỡng → return null để UI hiển thị placeholder.
const double _kMaxConvertValue = 1e25;

/// Convert `amountStr` từ `fromCode` sang `toCode` dựa trên list rate đã load.
///
/// Nếu [historyOverride] non-null → ưu tiên rate trong record cho các code có
/// trong record (`setHistoryRate`). Khi đang convert by history rate,
/// kết quả phản ánh tỷ giá lịch sử thay vì tỷ giá hiện tại của DB.
///
/// Trả null nếu parse fail, thiếu rate, hoặc kết quả vượt MAX.
String? convertCurrency(
  List<CurrencyRate> rates,
  String fromCode,
  String toCode,
  String amountStr, {
  CurrencyConvertHistory? historyOverride,
}) {
  final normalized = amountStr.endsWith('.') ? '${amountStr}0' : amountStr;
  final amount = double.tryParse(normalized);
  if (amount == null) return null;
  final fromRate = effectiveRateOf(rates, fromCode, historyOverride);
  final toRate = effectiveRateOf(rates, toCode, historyOverride);
  if (fromRate == null || toRate == null || toRate == 0) return null;

  final result = amount * fromRate / toRate;
  if (result.isNaN || result.isInfinite || result.abs() > _kMaxConvertValue) return null;

  return _stripTrailingZeros(result.toStringAsFixed(4));
}

/// `100.0000` → `100`, `1.5000` → `1.5`, `0.0000` → `0`.
String _stripTrailingZeros(String s) {
  if (!s.contains('.')) return s;
  var end = s.length;
  while (end > 0 && s[end - 1] == '0') {
    end--;
  }
  if (end > 0 && s[end - 1] == '.') end--;
  return end == 0 ? '0' : s.substring(0, end);
}

/// Trả rate cho [code]. Nếu [historyOverride] có chứa code → dùng rate từ
/// record (lịch sử); ngược lại fallback rate hiện tại trong [rates].
double? effectiveRateOf(List<CurrencyRate> rates, String code, CurrencyConvertHistory? historyOverride) {
  if (historyOverride != null) {
    final fromHistory = _rateFromHistory(historyOverride, code);
    if (fromHistory != null) return fromHistory;
  }
  return rateOf(rates, code);
}

double? _rateFromHistory(CurrencyConvertHistory h, String code) {
  if (h.currencyCode1 == code) return double.tryParse(h.exchangeRate1);
  if (h.currencyCode2 == code) return double.tryParse(h.exchangeRate2);
  if (h.currencyCode3 == code && h.exchangeRate3 != null) return double.tryParse(h.exchangeRate3!);
  if (h.currencyCode4 == code && h.exchangeRate4 != null) return double.tryParse(h.exchangeRate4!);
  return null;
}

/// `true` nếu [code] nằm trong 1 trong 4 currency của history record. Dùng để
/// quyết định khi user đổi currency có cần `stopConvertByHistoryRate` hay không.
bool historyContainsCode(CurrencyConvertHistory? h, String code) {
  if (h == null) return false;
  return h.currencyCode1 == code || h.currencyCode2 == code || h.currencyCode3 == code || h.currencyCode4 == code;
}

double? rateOf(List<CurrencyRate> rates, String code) {
  for (final r in rates) {
    if (r.code == code) return r.rate;
  }
  return null;
}

String currencyName(List<CurrencyRate> rates, String code) {
  for (final r in rates) {
    if (r.code == code) return r.name;
  }
  return code;
}

/// Port từ Android `getRateTimeCurrencyConvert`. Trả timestamp dùng cho:
/// - Hiển thị "rate as of ..." trên UI footer.
/// - Set `ratesLastUpdated` khi tạo history record mới.
///
/// Logic: nếu đang convert by history rate, ưu tiên record simple → advance.
/// Ngược lại dùng [serverTimeMs] (prefs, default 1656521701000).
DateTime rateTimeForDisplay({
  required CurrencyConvertHistory? historySimple,
  required CurrencyConvertHistory? historyAdvanced,
  required int serverTimeMs,
}) {
  if (historySimple != null) return historySimple.ratesLastUpdated;
  if (historyAdvanced != null) return historyAdvanced.ratesLastUpdated;
  return DateTime.fromMillisecondsSinceEpoch(serverTimeMs);
}

/// Newest rate time across all currencies — dùng để so sánh với
/// `history.ratesLastUpdated` quyết định có dùng history rate hay không.
DateTime? newestRateTime(List<CurrencyRate> rates) {
  DateTime? max;
  for (final r in rates) {
    final updatedAt = r.updatedAt;
    if (updatedAt == null) continue;
    if (max == null || updatedAt.isAfter(max)) max = updatedAt;
  }
  return max;
}
