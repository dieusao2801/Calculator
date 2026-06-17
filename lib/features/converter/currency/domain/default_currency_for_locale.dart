import 'dart:ui' show PlatformDispatcher;

import 'package:intl/intl.dart';

/// Trả về currency code theo locale của device (vd `vi_VN` → `VND`, `en_US` → `USD`).
///
/// Hai bước:
/// 1. Lấy locale device từ `PlatformDispatcher`.
/// 2. Hỏi `NumberFormat.simpleCurrency` ra `currencyName` (ISO 4217 code).
///
/// Nếu code thu được không có trong [knownCodes] (set codes đã seed trong DB),
/// fallback về [fallback]. Mặc định fallback `'USD'`.
String defaultCurrencyForDeviceLocale(
  Set<String> knownCodes, {
  String fallback = 'USD',
}) {
  try {
    final locale = PlatformDispatcher.instance.locale;
    final tag = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    final code = NumberFormat.simpleCurrency(locale: tag).currencyName;
    if (code != null && knownCodes.contains(code)) return code;
  } catch (_) {
    // ignore — fallback bên dưới
  }
  return fallback;
}
