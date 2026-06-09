import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/extensions/date_extension.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/core/widgets/list/app_option_item.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';

import '../../../../gen/assets.gen.dart';

enum HistoryAction { restoreCalculation, restoreResult, copy, share, edit, delete, lock }

class HistoryActionsDialog extends StatelessWidget {
  const HistoryActionsDialog({super.key, required this.item});

  final CalculationHistory item;

  static Future<HistoryAction?> show(BuildContext context, CalculationHistory item) {
    return AppBaseDialog.show<HistoryAction>(
      context: context,
      title: '${item.expression}=${item.result}',
      content: HistoryActionsDialog(item: item),
      actions: [
        TextButton(
          onPressed: () => context.maybePop(),
          child: Text(
            t.common.cancel.toUpperCase(),
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = item.createdTime.toFullDateTime();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date Time display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          alignment: Alignment.center,
          child: Text(
            dateStr,
            style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
        // Options List using Base Widget
        AppOptionItem(
          customIcon: Assets.svg.icRestore.svg(colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
          label: t.history.restore_calculation,
          onTap: () => context.maybePop(HistoryAction.restoreCalculation),
        ),
        AppOptionItem(
          customIcon: Assets.svg.icRestore.svg(colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
          label: t.history.restore_result,
          onTap: () => context.maybePop(HistoryAction.restoreResult),
        ),
        AppOptionItem(
          customIcon: Assets.svg.icCopyPlus.svg(colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
          label: t.common.copy,
          onTap: () => context.maybePop(HistoryAction.copy),
        ),
        AppOptionItem(icon: Icons.share, label: t.common.share, onTap: () => context.maybePop(HistoryAction.share)),
        AppOptionItem(icon: Icons.edit, label: t.common.edit, onTap: () => context.maybePop(HistoryAction.edit)),
        AppOptionItem(
          customIcon: Assets.svg.icDelete.svg(colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
          label: t.common.delete,
          onTap: () => context.maybePop(HistoryAction.delete),
        ),
        AppOptionItem(
          customIcon: Assets.svg.icLock.svg(colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn)),
          label: item.isLock ? t.common.unlock : t.common.lock,
          isLast: true,
          onTap: () => context.maybePop(HistoryAction.lock),
        ),
      ],
    );
  }
}
