import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/core/widgets/dialogs/info_dialog.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_converter_controller.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_rates_controller.dart';
import 'package:calculator/features/converter/currency/presentation/widgets/currency_toolbar.dart';
import 'package:calculator/features/converter/currency/presentation/widgets/currency_display_panel.dart';
import 'package:calculator/features/converter/currency/presentation/widgets/currency_keypad.dart';
import 'package:calculator/features/home/presentation/widgets/home_background.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class CurrencyConverterPage extends ConsumerStatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  ConsumerState<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends ConsumerState<CurrencyConverterPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRefreshOnEnter());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeRefreshOnEnter();
    }
  }

  Future<void> _maybeRefreshOnEnter() async {
    final ratesController = ref.read(currencyRatesControllerProvider.notifier);
    if (!await ratesController.shouldRefreshOnEnter()) return;
    if (!mounted) return;

    _showLoadingDialog();
    final ok = await ratesController.refresh();
    if (!mounted) return;
    context.maybePop();

    if (ok) {
      final converter = ref.read(currencyConverterControllerProvider.notifier);
      final currentMode = ref.read(currencyConverterControllerProvider).mode;
      converter.stopConvertByHistoryRate(currentMode);
      converter.recomputeAfterRatesChanged();
    } else {
      await _showErrorDialog(t.currency.update_rate_failed);
    }
  }

  Future<void> _showErrorDialog(String message) {
    return InfoDialog.show(context: context, title: t.currency.update_rate_title, message: message);
  }

  void _showLoadingDialog() {
    AppBaseDialog.show<void>(
      context: context,
      title: t.currency.update_rate_title,
      barrierDismissible: false,
      content: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.brandOrange),
          ),
          const SizedBox(width: AppDimens.gap16),
          Expanded(
            child: Text(
              t.currency.update_rate_loading,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: HomeBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Expanded(flex: 6, child: CurrencyDisplayPanel()),
              const SizedBox(height: 12),
              const Expanded(flex: 4, child: CurrencyKeypad()),
              const CurrencyToolbar(),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
