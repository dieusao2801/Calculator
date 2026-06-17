import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/features/converter/currency/presentation/dialogs/currency_history_dialog.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_converter_controller.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_rates_controller.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/router/home_tab.dart';
import '../../../../../core/router/navigation_provider.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/widgets/dialogs/app_base_dialog.dart';
import '../../domain/entities/currency_converter_mode.dart';
import '../../../../../features/converter/presentation/providers/converter_favorites_controller.dart';

enum CurrencyMenuAction { shortcut, favorite, refresh, mode, history, share, help, feedback, caution, settings }

class CurrencyToolbar extends ConsumerWidget {
  const CurrencyToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 56,
      margin: EdgeInsets.symmetric(horizontal: AppDimens.gap6),
      decoration: const BoxDecoration(color: AppColors.charcoalGray, borderRadius: BorderRadius.all(Radius.circular(8))),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.maybePop,
            ),
            Expanded(
              child: Text(
                t.currency.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Assets.svg.icTabCalculator.svg(colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              onPressed: () {
                ref.read(navigationControllerProvider.notifier).setTab(HomeTab.calculator);
              },
            ),
            PopupMenuButton<CurrencyMenuAction>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              // Điều chỉnh offset nhỏ lại để sát nút More hơn
              offset: const Offset(0, -460),
              position: PopupMenuPosition.over,
              // Hiển thị đè lên hoặc ngay trên anchor
              color: Colors.white,
              elevation: 4,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) => _handleMenuSelection(context, ref, value),
              itemBuilder: (context) {
                final mode = ref.watch(currencyConverterControllerProvider).mode;
                final isSimple = mode == CurrencyConverterMode.simple;
                final isFavorite = ref.watch(converterFavoritesControllerProvider).contains('currency_converter');

                return [
                  if (Platform.isAndroid)
                    _buildMenuItem(CurrencyMenuAction.shortcut, Assets.svg.icAppShortcut.svg(), t.currency.menu.add_shortcut),
                  _buildMenuItem(
                    CurrencyMenuAction.favorite,
                    isFavorite ? const Icon(Icons.favorite, size: 22) : const Icon(Icons.favorite_border, size: 22),
                    isFavorite ? t.currency.menu.unfavorite : t.currency.menu.favorite,
                  ),
                  _buildMenuItem(CurrencyMenuAction.refresh, Assets.svg.icNavRefresh.svg(), t.currency.menu.refresh),
                  _buildMenuItem(
                    CurrencyMenuAction.mode,
                    Assets.svg.icSwap.svg(),
                    isSimple ? t.currency.menu.advanced_mode : t.currency.menu.simple_mode,
                  ),
                  _buildMenuItem(CurrencyMenuAction.history, Assets.svg.icMenuPopupHistory.svg(), t.currency.menu.history),
                  _buildMenuItem(CurrencyMenuAction.share, Assets.svg.icPopupShare.svg(), t.currency.menu.share),
                  _buildMenuItem(CurrencyMenuAction.help, Assets.svg.icPopupHelp.svg(), t.currency.menu.help),
                  _buildMenuItem(CurrencyMenuAction.feedback, Assets.svg.icChatNote.svg(), t.currency.menu.feedback),
                  _buildMenuItem(CurrencyMenuAction.caution, Assets.svg.icPopupCaution.svg(), t.currency.menu.caution),
                  _buildMenuItem(CurrencyMenuAction.settings, Assets.svg.icPopupSetting.svg(), t.currency.menu.settings),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<CurrencyMenuAction> _buildMenuItem(CurrencyMenuAction value, Widget icon, String label) {
    return PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: ColorFiltered(colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn), child: icon),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, WidgetRef ref, CurrencyMenuAction value) {
    final ctl = ref.read(currencyConverterControllerProvider.notifier);
    final mode = ref.read(currencyConverterControllerProvider).mode;

    switch (value) {
      case CurrencyMenuAction.shortcut:
        _showAddShortcutDialog(context);
        break;
      case CurrencyMenuAction.favorite:
        ref.read(converterFavoritesControllerProvider.notifier).toggleFavorite('currency_converter');
        break;
      case CurrencyMenuAction.mode:
        ctl.setMode(mode == CurrencyConverterMode.simple ? CurrencyConverterMode.advanced : CurrencyConverterMode.simple);
        break;
      case CurrencyMenuAction.refresh:
        ref.read(currencyRatesControllerProvider.notifier).refresh();
        break;
      case CurrencyMenuAction.history:
        CurrencyHistoryDialog.show(context);
        break;
      case CurrencyMenuAction.share:
        _handleShare(ref);
        break;
      case CurrencyMenuAction.help:
      case CurrencyMenuAction.feedback:
      case CurrencyMenuAction.caution:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.calculator.coming_soon)));
        break;
      case CurrencyMenuAction.settings:
        ref.read(navigationControllerProvider.notifier).setTab(HomeTab.settings);
        break;
    }
  }

  void _showAddShortcutDialog(BuildContext context) {
    AppBaseDialog.show(
      context: context,
      title: t.currency.menu.add_shortcut,
      message: 'Do you want to add this converter shortcut to home screen?',
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.common.cancel)),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Launcher không hỗ trợ')));
          },
          child: Text(t.common.ok),
        ),
      ],
    );
  }

  void _handleShare(WidgetRef ref) {
    final state = ref.read(currencyConverterControllerProvider);
    String text = '';
    if (state.mode == CurrencyConverterMode.simple) {
      if (state.fromInput.isNotEmpty && state.toInput.isNotEmpty) {
        text = '${state.fromInput} ${state.fromCode} = ${state.toInput} ${state.toCode}';
      } else {
        text = 'Currency Converter: ${state.fromCode} to ${state.toCode}';
      }
    } else {
      text = 'Currency conversion with multiple currencies using Calculator AI';
    }
    Share.share(text);
  }
}
