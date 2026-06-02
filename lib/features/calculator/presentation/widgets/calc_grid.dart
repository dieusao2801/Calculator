import 'package:calculator/core/constants/calc_symbols.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_controller.dart';
import 'package:calculator/features/calculator/presentation/widgets/calc_button.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalcGrid extends ConsumerWidget {
  const CalcGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctl = ref.read(calculatorControllerProvider.notifier);

    final rows = <List<Widget>>[
      // Row 1 — function nâng cao
      [
        CalcButton(variant: CalcButtonVariant.function, label: CalcSymbols.sqrtPi, onPressed: ctl.sqrtPi),
        CalcButton(
          variant: CalcButtonVariant.function,
          label: CalcSymbols.power,
          onPressed: () => ctl.appendOperator(CalcSymbols.power),
        ),
        CalcButton(variant: CalcButtonVariant.function, label: CalcSymbols.squareLabel, onPressed: ctl.square),
        CalcButton(
          variant: CalcButtonVariant.function,
          svgIcon: Assets.svg.icUndo,
          onPressed: ctl.undo,
          iconSize: AppDimens.gap48,
        ),
      ],
      // Row 2 — function
      [
        CalcButton(variant: CalcButtonVariant.function, label: CalcSymbols.plusMinus, onPressed: ctl.plusMinus),
        CalcButton(variant: CalcButtonVariant.function, label: CalcSymbols.percent, onPressed: ctl.percent),
        CalcButton(variant: CalcButtonVariant.function, label: CalcSymbols.inverse, onPressed: ctl.inverse),
        CalcButton(
          variant: CalcButtonVariant.function,
          svgIcon: Assets.svg.icBackspace,
          onPressed: ctl.backspace,
          iconSize: AppDimens.gap48,
        ),
      ],
      // Row 3
      [
        CalcButton(variant: CalcButtonVariant.clear, label: CalcSymbols.clear, onPressed: ctl.clear),
        CalcButton(
          variant: CalcButtonVariant.operator,
          label: CalcSymbols.brackets,
          onPressed: () => ctl.appendOperator(CalcSymbols.brackets),
        ),
        CalcButton(variant: CalcButtonVariant.operator, label: CalcSymbols.tripleZero, onPressed: ctl.appendTripleZero),
        CalcButton(
          variant: CalcButtonVariant.operator,
          label: CalcSymbols.divide,
          onPressed: () => ctl.appendOperator(CalcSymbols.divide),
        ),
      ],
      // Row 4
      [
        _digit(ctl, CalcSymbols.digit7),
        _digit(ctl, CalcSymbols.digit8),
        _digit(ctl, CalcSymbols.digit9),
        CalcButton(
          variant: CalcButtonVariant.operator,
          label: CalcSymbols.times,
          onPressed: () => ctl.appendOperator(CalcSymbols.times),
        ),
      ],
      // Row 5
      [
        _digit(ctl, CalcSymbols.digit4),
        _digit(ctl, CalcSymbols.digit5),
        _digit(ctl, CalcSymbols.digit6),
        CalcButton(
          variant: CalcButtonVariant.operator,
          label: CalcSymbols.minus,
          onPressed: () => ctl.appendOperator(CalcSymbols.minus),
        ),
      ],
      // Row 6
      [
        _digit(ctl, CalcSymbols.digit1),
        _digit(ctl, CalcSymbols.digit2),
        _digit(ctl, CalcSymbols.digit3),
        CalcButton(
          variant: CalcButtonVariant.operator,
          label: CalcSymbols.plus,
          onPressed: () => ctl.appendOperator(CalcSymbols.plus),
        ),
      ],
      // Row 7
      [
        _digit(ctl, CalcSymbols.digit0),
        CalcButton(variant: CalcButtonVariant.digit, label: CalcSymbols.doubleZero, onPressed: ctl.appendDoubleZero),
        CalcButton(variant: CalcButtonVariant.digit, label: CalcSymbols.decimal, onPressed: ctl.appendDecimal),
        CalcButton(variant: CalcButtonVariant.equals, label: CalcSymbols.equals, onPressed: ctl.equals),
      ],
    ];

    return Padding(
      padding: const EdgeInsets.only(left: AppDimens.gap12, right: AppDimens.gap12, bottom: AppDimens.gap12),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppDimens.gap8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < rows[i].length; j++) ...[
                    if (j > 0) const SizedBox(width: AppDimens.gap8),
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

  CalcButton _digit(CalculatorController ctl, String d) {
    return CalcButton(variant: CalcButtonVariant.digit, label: d, onPressed: () => ctl.appendDigit(d));
  }
}
