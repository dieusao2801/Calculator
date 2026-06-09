import 'package:calculator/features/calculator/domain/usecases/delete_history.dart';
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
  /// Sau khi DB save xong, gắn id thật vào entry trong state để các action sau
  /// (delete, edit) có id chính xác. Gọi từ `equals()` khi user nhấn `=`.
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
    final newId = await ref.read(saveCalculationHistoryUseCaseProvider).call(entry);
    final list = state.value ?? const <CalculationHistory>[];
    // identical() đảm bảo replace đúng entry, không lẫn với record khác cùng expression
    state = AsyncData(list.map((e) => identical(e, entry) ? entry.copyWith(id: newId) : e).toList());
  }

  Future<void> updateNote(CalculationHistory item, String newNote) async {
    final updated = item.copyWith(note: newNote);
    await updateRecord(updated);
  }

  Future<void> updateRecord(CalculationHistory updated) async {
    state = await AsyncValue.guard(() async {
      await ref.read(updateCalculationHistoryUseCaseProvider).call(updated);
      final current = state.value ?? const <CalculationHistory>[];
      return current.map((h) => (h.id != null && h.id == updated.id) ? updated : h).toList();
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

  Future<void> deleteRecord(CalculationHistory updated) async {
    if (updated.id == null) return;
    final id = updated.id!;
    state = await AsyncValue.guard(() async {
      await ref.read(deleteHistoryUseCaseProvider).execute(id);
      final current = state.value ?? const <CalculationHistory>[];
      return current.where((e) => e.id != id).toList();
    });
  }

  Future<void> lockOrUnlockRecord(CalculationHistory item) {
    final updated = item.copyWith(isLock: !item.isLock);
    return updateRecord(updated);
  }
}
