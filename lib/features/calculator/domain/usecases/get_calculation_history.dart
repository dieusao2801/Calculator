import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:calculator/features/history/domain/repositories/calculation_history_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../history/data/providers/history_repository_providers.dart';

part 'get_calculation_history.g.dart';

class GetCalculationHistoryUseCase {
  final CalculationHistoryRepository _calculationHistoryRepository;

  GetCalculationHistoryUseCase(this._calculationHistoryRepository);

  Future<List<CalculationHistory>> execute() async {
    return await _calculationHistoryRepository.getAllHistory();
  }
}

@riverpod
GetCalculationHistoryUseCase getCalculationHistoryUseCase(Ref ref) {
  return GetCalculationHistoryUseCase(ref.watch(historyRepositoryProvider));
}
