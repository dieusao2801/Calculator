import 'package:calculator/features/history/data/providers/history_repository_providers.dart';
import 'package:calculator/features/history/domain/repositories/calculation_history_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'delete_all_history.g.dart';

class DeleteAllHistoryUseCase {
  final CalculationHistoryRepository _calculationHistoryRepository;

  DeleteAllHistoryUseCase(this._calculationHistoryRepository);

  Future<void> execute() async {
    await _calculationHistoryRepository.clearHistory();
  }
}

@riverpod
DeleteAllHistoryUseCase deleteAllHistoryUseCase(Ref ref) {
  return DeleteAllHistoryUseCase(ref.watch(historyRepositoryProvider));
}
