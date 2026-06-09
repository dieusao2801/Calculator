import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_controller.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_state.dart';
import 'package:calculator/features/calculator/presentation/widgets/calc_grid.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/logic/calculator_engine.dart';

class HistoryCalculatorOverlay extends StatelessWidget {
  const HistoryCalculatorOverlay({super.key, required this.initialItem});

  final CalculationHistory initialItem;

  static Future<CalculationHistory?> show(BuildContext context, CalculationHistory item) {
    return AppBaseDialog.show<CalculationHistory>(
      context: context,
      title: t.common.edit,
      showCloseButton: true,
      useBackgroundImage: true,
      content: HistoryCalculatorOverlay(initialItem: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Override calculatorControllerProvider để CalcGrid thao tác trên state cô lập,
    // không đụng vào controller chính (DB history, persist formula).
    return ProviderScope(
      overrides: [
        calculatorControllerProvider.overrideWith(
          () => _LocalCalculatorController(
            initialItem,
            onEquals: (updatedExpr, updatedResult) {
              final finalItem = initialItem.copyWith(expression: updatedExpr, result: updatedResult);
              context.maybePop(finalItem);
            },
          ),
        ),
      ],
      child: const _HistoryEditBody(),
    );
  }
}

class _HistoryEditBody extends ConsumerWidget {
  const _HistoryEditBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.gap16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLCD.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppDimens.gap16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                state.expression.isEmpty ? '0' : state.expression,
                style: AppTextStyles.calculatorExpression.copyWith(fontSize: 32, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimens.gap4),
              Text(
                state.previewResult.isNotEmpty ? state.previewResult : state.expression,
                style: AppTextStyles.calculatorPreview.copyWith(fontSize: 22, color: AppColors.textResultPreview),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gap16),
        const SizedBox(height: 420, child: CalcGrid(padding: EdgeInsets.zero)),
      ],
    );
  }
}

/// Bản local của CalculatorController dùng cho dialog edit history.
/// Chỉ override các method có side-effect ra ngoài (build/equals/persist).
class _LocalCalculatorController extends CalculatorController {
  _LocalCalculatorController(this.initial, {required this.onEquals});

  final CalculationHistory initial;
  final void Function(String expr, String result) onEquals;
  final _localEngine = CalculatorEngine();

  @override
  CalculatorState build() {
    return CalculatorState(
      expression: initial.expression,
      previewResult: initial.result,
      cursorIndex: initial.expression.length,
    );
  }

  @override
  Future<void> persistExpression() async {}

  @override
  void equals() {
    final result = _localEngine.evaluate(state.expression, isStrict: true);
    if (result.errorKey != null) {
      state = state.copyWith(errorMessage: result.errorKey);
      return;
    }
    final finalResult = result.result ?? '0';
    onEquals(state.expression, finalResult);
  }
}
