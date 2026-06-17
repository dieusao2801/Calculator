import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_converter_controller.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_history_controller.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dialog hiển thị danh sách history. Click 1 item → fill state + đóng dialog.
class CurrencyHistoryDialog {
  CurrencyHistoryDialog._();

  static Future<void> show(BuildContext context) {
    return AppBaseDialog.show<void>(
      context: context,
      title: t.currency.history_title,
      showCloseButton: true,
      expandContent: true,
      content: const _HistoryContent(),
    );
  }
}

class _HistoryContent extends ConsumerWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(currencyHistoryControllerProvider);
    final list = async.value ?? const <CurrencyConvertHistory>[];

    if (async.isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    if (list.isEmpty) {
      return Center(
        child: Text(t.currency.history_empty, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      );
    }

    // Body slot đã tight fit từ AppBaseDialog → ListView nhận bounded constraint
    // trực tiếp, tự scroll khi list dài, không cần shrinkWrap.
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: list.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _HistoryItem(
        history: list[i],
        onTap: () {
          ref.read(currencyConverterControllerProvider.notifier).loadFromHistory(list[i]);
          context.maybePop();
        },
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.history, required this.onTap});

  final CurrencyConvertHistory history;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = history;
    final isAdvanced = h.currencyCode3 != null && h.currencyCode4 != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.gap10, horizontal: AppDimens.gap8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(h.currencyCode1, h.amount1),
            const SizedBox(height: 4),
            _line(h.currencyCode2, h.amount2),
            if (isAdvanced) ...[
              const SizedBox(height: 4),
              _line(h.currencyCode3!, h.amount3 ?? ''),
              const SizedBox(height: 4),
              _line(h.currencyCode4!, h.amount4 ?? ''),
            ],
            const SizedBox(height: 6),
            Text(_formatTime(h.createdTime), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _line(String code, String amount) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(code, style: AppTextStyles.labelLarge)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            amount,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime t) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(t.day)}/${pad(t.month)}/${t.year} ${pad(t.hour)}:${pad(t.minute)}';
  }
}
