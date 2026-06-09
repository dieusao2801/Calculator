import 'package:calculator/features/history/data/providers/history_repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../history/domain/repositories/calculation_history_repository.dart';
part 'delete_history.g.dart';

class DeleteHistoryUseCase {
  final CalculationHistoryRepository _calculationHistoryRepository;

  DeleteHistoryUseCase(this._calculationHistoryRepository);

  Future<void> execute(int id) async {
    await _calculationHistoryRepository.deleteHistory(id);
  }
}

@riverpod
DeleteHistoryUseCase deleteHistoryUseCase(Ref ref) {
  return DeleteHistoryUseCase(ref.watch(historyRepositoryProvider));
}
