import 'package:calculator/core/helpers/app_toast.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_controller.dart';
import 'package:calculator/features/calculator/presentation/widgets/calc_grid.dart';
import 'package:calculator/features/calculator/presentation/widgets/display_panel.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalculatorTab extends ConsumerWidget {
  const CalculatorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe lỗi để hiển thị Toast
    ref.listen(calculatorControllerProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null) {
        AppToast.show(context, _mapErrorKeyToMessage(next));
        // Xóa lỗi ngay sau khi hiện để có thể hiện lại nếu bấm tiếp cùng lỗi đó
        ref.read(calculatorControllerProvider.notifier).clearErrorMessage();
      }
    });

    final state = ref.watch(calculatorControllerProvider);

    return Column(
      children: [
        DisplayPanel(state: state),
        const SizedBox(height: AppDimens.gap16),
        const Expanded(child: CalcGrid()),
      ],
    );
  }

  String _mapErrorKeyToMessage(String key) {
    switch (key) {
      case 'divide_by_zero':
        return t.calculator.error_divide_by_zero;
      case 'max_digits_exceeded':
        return t.calculator.max_digits_exceeded;
      case 'coming_soon':
        return t.calculator.coming_soon;
      default:
        return t.calculator.error_generic;
    }
  }
}
