import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/converter/currency/domain/currency_conversion.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_converter_controller.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_converter_state.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_rates_controller.dart';
import 'package:calculator/features/converter/currency/presentation/widgets/currency_dropdown.dart';
import 'package:calculator/features/converter/currency/presentation/widgets/currency_input.dart';
import 'package:calculator/features/converter/currency/presentation/dialogs/currency_selector_dialog.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../../../../../core/styles/app_text_styles.dart';
import '../../domain/entities/currency_converter_mode.dart';

class CurrencyDisplayPanel extends ConsumerWidget {
  const CurrencyDisplayPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currencyConverterControllerProvider);
    final rates = ref.watch(currencyRatesControllerProvider).value ?? const <CurrencyRate>[];
    final isSimple = state.mode == CurrencyConverterMode.simple;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.gap10),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: const Color(0xFFD3E6E9), borderRadius: BorderRadius.circular(14)),
        child: isSimple ? _buildSimple(context, state, rates, ref) : _buildAdvanced(state, rates, ref),
      ),
    );
  }

  Widget _buildSimple(BuildContext context, CurrencyConverterState state, List<CurrencyRate> rates, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label(t.currency.label_from.toUpperCase(), bold: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: CurrencyDropdown(
                        label: currencyName(rates, state.fromCode),
                        onTap: () async {
                          final code = await CurrencySelectorDialog.show(
                            context,
                            title: t.currency.label_from,
                            selectedCode: state.fromCode,
                          );
                          if (code != null) {
                            ref.read(currencyConverterControllerProvider.notifier).setFromCurrency(code);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: CurrencyInput(
                        value: state.fromInput,
                        focused: state.focusedFieldIndex == 0,
                        onTap: () => ref.read(currencyConverterControllerProvider.notifier).focusField(0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                _label(t.currency.label_to.toUpperCase(), bold: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: CurrencyDropdown(
                        label: currencyName(rates, state.toCode),
                        onTap: () async {
                          final code = await CurrencySelectorDialog.show(
                            context,
                            title: t.currency.label_to,
                            selectedCode: state.toCode,
                          );
                          if (code != null) {
                            ref.read(currencyConverterControllerProvider.notifier).setToCurrency(code);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: CurrencyInput(
                        value: state.toInput,
                        focused: state.focusedFieldIndex == 1,
                        onTap: () => ref.read(currencyConverterControllerProvider.notifier).focusField(1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(alignment: Alignment.bottomRight, child: _footer(context, ref, state, rates)),
        ],
      ),
    );
  }

  Widget _buildAdvanced(CurrencyConverterState state, List<CurrencyRate> rates, WidgetRef ref) {
    final ctl = ref.read(currencyConverterControllerProvider.notifier);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < state.advancedCodes.length; i++) ...[
                  if (i > 0) const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: CurrencyDropdown(
                          label: currencyName(rates, state.advancedCodes[i]),
                          onTap: () async {
                            final code = await CurrencySelectorDialog.show(
                              context,
                              title: t.currency.label_advanced(index: i + 1),
                              selectedCode: state.advancedCodes[i],
                            );
                            if (code != null) {
                              ctl.setAdvancedCurrency(i, code);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: CurrencyInput(
                          value: ctl.displayForAdvancedIndex(i),
                          focused: state.focusedFieldIndex == i,
                          onTap: () => ctl.focusField(i),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text, {bool bold = false}) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      color: const Color(0xFF5A6E71),
      letterSpacing: 0.5,
    ),
  );

  Widget _footer(BuildContext context, WidgetRef ref, CurrencyConverterState state, List<CurrencyRate> rates) {
    final historySimple = state.historyRecordSimple;
    final isHistory = state.isConvertByHistoryRate;

    final updatedAt = rateTimeForDisplay(
      historySimple: state.historyRecordSimple,
      historyAdvanced: state.historyRecordAdvanced,
      serverTimeMs: ref.watch(appPrefsProvider).currencyTimeServer,
    );

    // Ratio dùng cùng helper convert (effective rate override theo history nếu có).
    final converted = convertCurrency(rates, state.fromCode, state.toCode, '1', historyOverride: historySimple);
    final String rateText;
    if (converted == null) {
      rateText = '—';
    } else {
      final approximately = (double.tryParse(converted) ?? 1.0) == 0 ? '~' : '';
      rateText = '$approximately$converted';
    }

    final timeText = _formatTime(updatedAt);
    final historyPrefix = isHistory ? '${t.currency.history_label} ' : '';

    return Container(
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% chiều rộng màn hình
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            historyPrefix + t.currency.rate_as_of(time: timeText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            t.currency.rate_line(from: state.fromCode, rate: rateText, to: state.toCode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) => DateFormat('dd MMM yyyy HH:mm:ss').format(t);
}
