import 'package:calculator/core/helpers/app_toast.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/widgets/sheets/app_bottom_sheet.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_controller.dart';
import 'package:calculator/features/calculator/presentation/widgets/calc_grid.dart';
import 'package:calculator/features/calculator/presentation/widgets/display_panel.dart';
import 'package:calculator/features/calculator/presentation/sheets/calc_history_sheet.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../providers/calculator_history_controller.dart';

class CalculatorTab extends ConsumerStatefulWidget {
  const CalculatorTab({super.key});

  @override
  ConsumerState<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends ConsumerState<CalculatorTab> {
  final GlobalKey _displayPanelKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Lắng nghe lỗi để hiển thị Toast
    ref.listen(calculatorControllerProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null) {
        AppToast.show(context, _mapErrorKeyToMessage(next));
        ref.read(calculatorControllerProvider.notifier).clearErrorMessage();
      }
    });

    final state = ref.watch(calculatorControllerProvider);

    return Column(
      children: [
        DisplayPanel(key: _displayPanelKey, state: state, onHistoryTap: _showHistorySheet),
        const SizedBox(height: AppDimens.gap16),
        const Expanded(child: CalcGrid()),
      ],
    );
  }

  void _showHistorySheet() {
    final renderBox = _displayPanelKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final panelBottomY = renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height;
    // useSafeArea: true → SafeArea(bottom: false). Sheet sát đáy màn hình, nên
    // maxHeight = khoảng từ bottom panel xuống đáy screen.
    final maxHeight = (screenHeight - panelBottomY).clamp(0.0, screenHeight);
    AppBottomSheet.show(
      context: context,
      title: t.history.title,
      mode: AppBottomSheetMode.draggable,
      dismissOnDragDown: true,
      maxHeight: maxHeight,
      headerBackgroundColor: const Color(0xFF393939),
      headerForegroundColor: Colors.white,
      backgroundColor: const Color(0xFFE0E0E0),
      actions: [
        IconButton(
          icon: const Icon(Icons.help, color: Colors.white, size: 24),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Consumer(
          builder: (context, ref, _) {
            final isEmpty = ref.watch(calculatorHistoryControllerProvider).value?.isEmpty ?? true;
            if (isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete, color: Colors.white, size: 24),
              onPressed: () => _onDeleteAllHistory(context, ref),
            );
          },
        ),
      ],
      child: const CalcHistorySheet(),
    );
  }

  String _mapErrorKeyToMessage(String key) {
    switch (key) {
      case 'divide_by_zero':
        return t.calculator.error_divide_by_zero;
      case 'max_digits_exceeded':
        return t.calculator.max_digits_exceeded;
      case 'coming_soon':
        return t.calculator.coming_soon;
      default:
        return t.calculator.error_generic;
    }
  }

  void _onDeleteAllHistory(BuildContext context, WidgetRef ref) {
    ConfirmDialog.show(
      context: context,
      title: t.history.delete_history,
      message: t.history.msg_delete_history,
      onPositive: () async {
        await ref.read(calculatorControllerProvider.notifier).persistExpression();
        // Gọi hàm xử lý tập trung trong Controller
        await ref.read(calculatorHistoryControllerProvider.notifier).clearAll();
      },
    );
  }
}
