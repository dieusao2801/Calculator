import 'package:calculator/features/calculator/domain/usecases/get_calculation_history.dart';
import 'package:calculator/features/calculator/domain/usecases/save_calculation_history.dart';
import 'package:calculator/features/calculator/domain/usecases/update_calculation_history.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/delete_all_history.dart';

part 'calculator_history_controller.g.dart';

@riverpod
class CalculatorHistoryController extends _$CalculatorHistoryController {
  @override
  Future<List<CalculationHistory>> build() {
    return ref.watch(getCalculationHistoryUseCaseProvider).execute();
  }

  /// Thêm 1 record mới: optimistic prepend vào list local, save DB ngầm.
  /// Gọi từ `equals()` khi user nhấn `=`.
  Future<void> addRecord({required String expression, required String result}) async {
    final entry = CalculationHistory(
      expression: expression,
      result: result,
      isLock: false,
      note: '',
      createdTime: DateTime.now(),
    );
    final current = state.value ?? const <CalculationHistory>[];
    state = AsyncData([entry, ...current]);
    await ref.read(saveCalculationHistoryUseCaseProvider).call(expression: expression, result: result);
  }

  Future<void> updateNote(CalculationHistory item, String newNote) async {
    final updated = item.copyWith(note: newNote);
    state = await AsyncValue.guard(() async {
      await ref.read(updateCalculationHistoryUseCaseProvider).call(updated);
      final current = state.value ?? const <CalculationHistory>[];
      return current.map((h) => h.id == updated.id ? updated : h).toList();
    });
  }

  Future<void> clearAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Xóa sạch lịch sử
      await ref.read(deleteAllHistoryUseCaseProvider).execute();

      // 2. Refresh lại chính nó (về list rỗng)
      return const <CalculationHistory>[];
    });

    // 3. (Nếu cần) Tự động refresh các Provider liên quan khác
    ref.invalidate(getCalculationHistoryUseCaseProvider);
  }
}
