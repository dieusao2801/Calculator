import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/helpers/share_helper.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';

class HistoryShareDialog extends StatelessWidget {
  const HistoryShareDialog({super.key, required this.item});

  final CalculationHistory item;

  static Future<void> show(BuildContext context, CalculationHistory item) {
    return AppBaseDialog.show<void>(
      context: context,
      title: 'General Calculator',
      content: HistoryShareDialog(item: item),
      actions: [
        TextButton(
          onPressed: () => context.maybePop(),
          child: Text(
            t.common.cancel.toUpperCase(),
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () async {
            final shareText = _getShareText(item);
            await ShareHelper.shareText(shareText);
            if (context.mounted) context.maybePop();
          },
          child: Text(
            t.common.share.toUpperCase(),
            style: const TextStyle(color: AppColors.brandOrange, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static String _getShareText(CalculationHistory item) {
    return '${item.expression}\n=${item.result}\n\nvia Calculator\nhttps://play.google.com/store/apps/details?id=com.tohsoft.calculator';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.expression, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        Text('=${item.result}', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Text('via Calculator', style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87)),
        Text(
          'https://play.google.com/store/apps/details?id=com.tohsoft.calculator',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}
