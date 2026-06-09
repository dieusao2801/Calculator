import 'package:calculator/features/calculator/data/providers/calculator_preferences_providers.dart';
import 'package:calculator/features/calculator/domain/repositories/calculator_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_last_formula.g.dart';

class SaveLastFormulaUseCase {
  SaveLastFormulaUseCase(this._repository);

  final CalculatorPrefRepository _repository;

  Future<void> execute(String formula) => _repository.saveLastFormula(formula);
}

@riverpod
SaveLastFormulaUseCase saveLastFormulaUseCase(Ref ref) {
  return SaveLastFormulaUseCase(ref.watch(calculatorPreferencesRepositoryProvider));
}
