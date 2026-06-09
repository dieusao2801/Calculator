import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/calculator/domain/repositories/calculator_preferences_repository.dart';

class CalculatorPrefRepositoryImpl implements CalculatorPrefRepository {
  CalculatorPrefRepositoryImpl(this._prefs);

  final AppPrefs _prefs;

  @override
  Future<String> getLastFormula() async => _prefs.lastFormula;

  @override
  Future<void> saveLastFormula(String formula) => _prefs.setLastFormula(formula);
}
