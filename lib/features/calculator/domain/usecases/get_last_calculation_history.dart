import 'package:calculator/features/history/domain/repositories/calculation_history_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../history/data/providers/history_repository_providers.dart';
import '../../../history/domain/entities/calculation_history.dart';

part 'get_last_calculation_history.g.dart';

class GetLastCalculationHistoryUseCase {
  final CalculationHistoryRepository _calculationHistoryRepository;

  GetLastCalculationHistoryUseCase(this._calculationHistoryRepository);

  Future<CalculationHistory?> execute() async {
    return await _calculationHistoryRepository.getLastHistory();
  }
}

@riverpod
GetLastCalculationHistoryUseCase getLastCalculationHistoryUseCase(Ref ref) {
  return GetLastCalculationHistoryUseCase(ref.watch(historyRepositoryProvider));
}
