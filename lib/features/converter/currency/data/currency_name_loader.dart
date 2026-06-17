import 'dart:convert';

import 'package:calculator/core/log/app_log.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/services.dart';

/// Port `getDataOfCurrencyInAppLanguage` từ Android.
/// Load file `assets/currency_data/<languageCode>/currency.json` theo locale
/// hiện tại của app (Slang). Lỗi đọc/parse → trả map rỗng (sát code gốc).
Future<Map<String, String>> loadCurrencyNamesForCurrentLanguage() async {
  final lang = LocaleSettings.currentLocale.languageCode;
  final path = 'assets/currency_data/$lang/currency.json';
  try {
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as String));
  } catch (e) {
    AppLog.e('loadCurrencyNamesForCurrentLanguage($path): $e');
    return const {};
  }
}
