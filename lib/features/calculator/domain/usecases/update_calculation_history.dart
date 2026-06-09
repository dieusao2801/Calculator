import 'package:calculator/features/history/domain/repositories/calculation_history_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../history/data/providers/history_repository_providers.dart';
import '../../../history/domain/entities/calculation_history.dart';

part 'update_calculation_history.g.dart';

class UpdateCalculationHistoryUseCase {
  final CalculationHistoryRepository _historyRepository;

  UpdateCalculationHistoryUseCase(this._historyRepository);

  Future<bool> call(CalculationHistory calculationHistory) {
    return _historyRepository.updateHistory(calculationHistory).then((value) => true).catchError((error) => false);
  }
}

@riverpod
UpdateCalculationHistoryUseCase updateCalculationHistoryUseCase(Ref ref) {
  return UpdateCalculationHistoryUseCase(ref.watch(historyRepositoryProvider));
}
