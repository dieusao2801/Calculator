import 'package:calculator/features/history/data/providers/history_repository_providers.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:calculator/features/history/domain/repositories/calculation_history_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_calculation_history.g.dart';

/// UseCase: persist 1 record vào history. Trả về id mới do DB sinh ra,
/// caller dùng id này để cập nhật state UI (đồng bộ với DB).
class SaveCalculationHistoryUseCase {
  SaveCalculationHistoryUseCase(this._historyRepository);

  final CalculationHistoryRepository _historyRepository;

  Future<int> call(CalculationHistory entity) {
    return _historyRepository.saveHistory(entity);
  }
}

@riverpod
SaveCalculationHistoryUseCase saveCalculationHistoryUseCase(Ref ref) {
  return SaveCalculationHistoryUseCase(ref.watch(historyRepositoryProvider));
}
