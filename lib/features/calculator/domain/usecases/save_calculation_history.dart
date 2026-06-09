import 'package:calculator/features/history/data/providers/history_repository_providers.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:calculator/features/history/domain/repositories/calculation_history_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_calculation_history.g.dart';

/// UseCase: đóng gói expression + result thành entity rồi persist vào history.
///
/// Lưu ý: chỉ tách ra khỏi controller khi cần compose nhiều bước (build entity
/// + save). Nếu sau này thêm analytics/sync/streak thì hợp lý mở rộng tại đây.
class SaveCalculationHistoryUseCase {
  SaveCalculationHistoryUseCase(this._historyRepository);

  final CalculationHistoryRepository _historyRepository;

  Future<void> call({required String expression, required String result, String note = ''}) {
    final entry = CalculationHistory(
      expression: expression,
      result: result,
      isLock: false,
      note: note,
      createdTime: DateTime.now(),
    );
    return _historyRepository.saveHistory(entry);
  }
}

@riverpod
SaveCalculationHistoryUseCase saveCalculationHistoryUseCase(Ref ref) {
  return SaveCalculationHistoryUseCase(ref.watch(historyRepositoryProvider));
}
