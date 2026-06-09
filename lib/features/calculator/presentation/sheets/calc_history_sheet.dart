import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/extensions/date_extension.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/widgets/dialogs/input_dialog.dart';
import 'package:calculator/features/calculator/presentation/dialogs/history_actions_dialog.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_controller.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_history_controller.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../history/domain/entities/calculation_history.dart';

class CalcHistorySheet extends ConsumerWidget {
  const CalcHistorySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(calculatorHistoryControllerProvider);

    return historyAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(child: Text(t.history.no_history_yet));
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final emptyNote = item.note.isEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => _onItemTap(context, ref, item),
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppDimens.gap16, top: AppDimens.gap6, bottom: AppDimens.gap6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item.createdTime.formatTime(),
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                emptyNote
                                    ? IconButton(
                                        icon: Assets.svg.icChatNote.svg(
                                          width: 24,
                                          height: 24,
                                          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _onEditNoteTap(context, ref, item),
                                      )
                                    : TextButton(
                                        onPressed: () => _onEditNoteTap(context, ref, item),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          item.note,
                                          style: TextStyle(fontSize: 16, color: Colors.blue.shade600, height: 1.0),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                IconButton(
                                  onPressed: () => _onMoreTap(context, ref, item),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.more_vert, size: 24, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: emptyNote ? 0 : AppDimens.gap8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: AppDimens.gap18),
                            child: RichText(
                              textAlign: TextAlign.right,
                              text: TextSpan(
                                style: const TextStyle(fontSize: 18, color: AppColors.textPrimary, height: 1.0),
                                children: [
                                  TextSpan(
                                    text: item.expression,
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.black38,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' = ',
                                    style: TextStyle(color: Colors.blue.shade600),
                                  ),
                                  TextSpan(
                                    text: item.result,
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.15)),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandOrange)),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  void _onItemTap(BuildContext context, WidgetRef ref, CalculationHistory item) {
    ref.read(calculatorControllerProvider.notifier).updateFromHistory(item.expression, item.result);
    context.maybePop();
  }

  void _onEditNoteTap(BuildContext context, WidgetRef ref, CalculationHistory item) {
    InputDialog.show(
      context: context,
      title: t.common.edit,
      initialValue: item.note,
      hintText: t.common.add_note_here,
      onConfirm: (newNote) => ref.read(calculatorHistoryControllerProvider.notifier).updateNote(item, newNote),
    );
  }

  void _onMoreTap(BuildContext context, WidgetRef ref, CalculationHistory item) async {
    final result = await HistoryActionsDialog.show(context, item);
    if (result == null) return;
    final calculatorController = ref.read(calculatorControllerProvider.notifier);
    switch (result) {
      case HistoryAction.restoreCalculation:
        calculatorController.restoreCalculation(item);
      case HistoryAction.restoreResult:
        calculatorController.restoreResult(item);
      case HistoryAction.copy:
        // TODO: Handle this case.
        throw UnimplementedError();
      case HistoryAction.share:
        // TODO: Handle this case.
        throw UnimplementedError();
      case HistoryAction.edit:
        // TODO: Handle this case.
        throw UnimplementedError();
      case HistoryAction.delete:
        // TODO: Handle this case.
        throw UnimplementedError();
      case HistoryAction.lock:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
