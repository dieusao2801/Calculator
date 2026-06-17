import 'package:calculator/features/calculator/presentation/widgets/calc_button.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_converter_controller.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dialogs/currency_history_dialog.dart';

class CurrencyKeypad extends ConsumerWidget {
  const CurrencyKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.read(currencyConverterControllerProvider.notifier);

    final rows = <List<Widget>>[
      [
        _digit(ctl, '7'),
        _digit(ctl, '8'),
        _digit(ctl, '9'),
        CalcButton(
          variant: CalcButtonVariant.function,
          svgIcon: Assets.svg.icBackspace,
          onPressed: ctl.backspace,
          iconSize: 48,
        ),
      ],
      [
        _digit(ctl, '4'),
        _digit(ctl, '5'),
        _digit(ctl, '6'),
        CalcButton(variant: CalcButtonVariant.function, svgIcon: Assets.svg.icSwap, onPressed: ctl.swap, iconSize: 24),
      ],
      [
        _digit(ctl, '1'),
        _digit(ctl, '2'),
        _digit(ctl, '3'),
        CalcButton(
          variant: CalcButtonVariant.function,
          svgIcon: Assets.svg.icMathematics,
          onPressed: () => CurrencyHistoryDialog.show(context),
          iconSize: 24,
        ),
      ],
      [
        _digit(ctl, '0'),
        CalcButton(variant: CalcButtonVariant.digit, label: '00', onPressed: () => ctl.appendDigit('00')),
        CalcButton(variant: CalcButtonVariant.digit, label: '.', onPressed: () => ctl.appendDigit('.')),
        CalcButton(variant: CalcButtonVariant.clear, label: 'C', onPressed: ctl.clearAll),
      ],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < rows[i].length; j++) ...[
                    if (j > 0) const SizedBox(width: 8),
                    Expanded(child: rows[i][j]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _digit(CurrencyConverterController ctl, String label) {
    return CalcButton(variant: CalcButtonVariant.digit, label: label, onPressed: () => ctl.appendDigit(label));
  }
}
