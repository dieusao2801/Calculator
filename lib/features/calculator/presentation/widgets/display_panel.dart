import 'package:calculator/core/theme/app_theme_ext.dart';
import 'package:calculator/core/widgets/auto_fit_text.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_controller.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_history_controller.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/styles/app_dimens.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../domain/logic/calculator_engine.dart';

class DisplayPanel extends ConsumerWidget {
  const DisplayPanel({super.key, required this.state, this.onHistoryTap});

  final CalculatorState state;
  final VoidCallback? onHistoryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme.display;
    final engine = CalculatorEngine();
    final formattedExpression = engine.formatFullExpression(state.expression);

    // Derive dòng history từ record mới nhất trong DB.
    final lastRecord = ref.watch(calculatorHistoryControllerProvider.select((s) => s.value?.firstOrNull));
    final historyLine = lastRecord != null ? "${lastRecord.expression} = ${lastRecord.result}" : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.gap8),
      padding: const EdgeInsets.all(AppDimens.gap3),
      decoration: BoxDecoration(color: theme.bgOuter, borderRadius: BorderRadius.circular(AppDimens.gap11)),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.gap3),
        decoration: BoxDecoration(color: const Color(0xFF8D8D8D), borderRadius: BorderRadius.circular(AppDimens.gap11)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppDimens.gap16, AppDimens.gap8, AppDimens.gap16, AppDimens.gap8),
          decoration: BoxDecoration(color: theme.bgInner, borderRadius: BorderRadius.circular(AppDimens.gap11)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // HISTORY
              Visibility(
                visible: historyLine.isNotEmpty,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onHistoryTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            historyLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.displayHistory.copyWith(color: theme.textSecondary, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.history_rounded, size: 20, color: theme.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // EXPRESSION
              AutoFitText(
                text: formattedExpression,
                rawText: state.expression,
                maxFontSize: AppTextStyles.displayExpression.fontSize!,
                minFontSize: 20,
                color: theme.textPrimary,
                fontWeight: AppTextStyles.displayExpression.fontWeight!,
                textAlign: TextAlign.right,
                showCursor: true,
                cursorIndex: state.cursorIndex,
                onTap: (index) {
                  ref.read(calculatorControllerProvider.notifier).moveCursor(index);
                },
              ),

              const SizedBox(height: 8),

              // RESULT
              AutoFitText(
                text: state.previewResult,
                maxFontSize: 30,
                minFontSize: 16,
                color: theme.textSecondary,
                fontWeight: AppTextStyles.displayResult.fontWeight!,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
