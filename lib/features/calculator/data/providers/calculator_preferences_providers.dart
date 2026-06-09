import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/calculator/data/repositories/calculator_preferences_repository_impl.dart';
import 'package:calculator/features/calculator/domain/repositories/calculator_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calculator_preferences_providers.g.dart';

@Riverpod(keepAlive: true)
CalculatorPrefRepository calculatorPreferencesRepository(Ref ref) {
  return CalculatorPrefRepositoryImpl(ref.watch(appPrefsProvider));
}
