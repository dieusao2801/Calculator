import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:flutter/material.dart';

import '../../../../core/helpers/clipboard_helper.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/widgets/dialogs/app_base_dialog.dart';
import '../../../../gen/strings.g.dart';

class HistoryCopyCalculationDialog extends StatelessWidget {
  const HistoryCopyCalculationDialog({super.key, required this.item});

  final CalculationHistory item;

  static Future<void> show(BuildContext context, CalculationHistory item) {
    return AppBaseDialog.show<void>(
      context: context,
      title: '${item.expression}=${item.result}',
      content: HistoryCopyCalculationDialog(item: item),
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
    // 3 lựa chọn copy: expression, result, full
    final options = <String>[item.expression, '${item.expression}=${item.result}', item.result];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < options.length; i++) ...[
          InkWell(
            onTap: () async {
              await ClipboardHelper.copy(options[i], context: context);
              if (context.mounted) context.maybePop();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimens.gap4),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(options[i], style: AppTextStyles.bodyMedium),
            ),
          ),
          AppStyles.divider(),
        ],
      ],
    );
  }
}
