import 'package:calculator/features/calculator/data/providers/calculator_preferences_providers.dart';
import 'package:calculator/features/calculator/domain/repositories/calculator_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_last_formula.g.dart';

class GetLastFormulaUseCase {
  GetLastFormulaUseCase(this._repository);

  final CalculatorPrefRepository _repository;

  Future<String> execute() => _repository.getLastFormula();
}

@riverpod
GetLastFormulaUseCase getLastFormulaUseCase(Ref ref) {
  return GetLastFormulaUseCase(ref.watch(calculatorPreferencesRepositoryProvider));
}
