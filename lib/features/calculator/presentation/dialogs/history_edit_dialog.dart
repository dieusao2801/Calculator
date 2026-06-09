import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/extensions/date_extension.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_styles.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';

import 'history_calculator_overlay.dart';

class HistoryEditDialog extends StatefulWidget {
  const HistoryEditDialog({super.key, required this.initialItem});

  final CalculationHistory initialItem;

  static Future<CalculationHistory?> show(BuildContext context, CalculationHistory item) {
    return AppBaseDialog.show<CalculationHistory>(
      context: context,
      title: t.common.edit,
      content: HistoryEditDialog(initialItem: item),
    );
  }

  @override
  State<HistoryEditDialog> createState() => _HistoryEditDialogState();
}

class _HistoryEditDialogState extends State<HistoryEditDialog> {
  late CalculationHistory _currentItem = widget.initialItem;

  Future<void> _openOverlay() async {
    final updated = await HistoryCalculatorOverlay.show(context, _currentItem);
    if (updated == null || !mounted) return;
    setState(() => _currentItem = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.gap20),
            border: Border.all(color: Colors.black12),
          ),
          alignment: Alignment.center,
          child: Text(
            _currentItem.createdTime.toFullDateTime(),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: AppDimens.gap16),
        InkWell(
          onTap: _openOverlay,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
                child: Text(_currentItem.expression, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
              ),
              AppStyles.divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
                child: Text(
                  _currentItem.result,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gap16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => context.maybePop(),
              child: Text(
                t.common.cancel.toUpperCase(),
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppDimens.gap8),
            TextButton(
              onPressed: () => context.maybePop(_currentItem),
              child: Text(
                t.common.ok.toUpperCase(),
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
