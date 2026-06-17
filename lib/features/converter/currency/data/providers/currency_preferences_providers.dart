import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/converter/currency/domain/repositories/currency_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/currency_preferences_repository_impl.dart';

part 'currency_preferences_providers.g.dart';

@Riverpod(keepAlive: true)
CurrencyPreferencesRepository currencyPreferencesRepository(Ref ref) {
  return CurrencyPreferencesRepositoryImpl(ref.watch(appPrefsProvider));
}
