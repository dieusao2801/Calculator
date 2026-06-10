import 'package:calculator/core/helpers/keyboard_provider.dart';
import 'package:calculator/core/router/home_tab.dart';
import 'package:calculator/core/router/navigation_provider.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/theme/app_theme_ext.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab bar dưới đáy với 4 mục AI Tour / Converter / Calculator / Settings.
class MenuTabs extends ConsumerWidget {
  const MenuTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _MenuTabsContent();
  }
}

class _MenuTabsContent extends ConsumerWidget {
  const _MenuTabsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme.menu;
    // Sử dụng provider để lắng nghe trạng thái bàn phím một cách reactive
    final isKeyboardVisible = ref.watch(keyboardVisibilityProvider);

    return isKeyboardVisible
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: AppDimens.gap8),
            decoration: BoxDecoration(color: theme.bg, borderRadius: BorderRadius.circular(AppDimens.gap12)),
            child: Row(
              children: [
                _tab(ref, theme, HomeTab.recent, Assets.svg.icTabRecents, t.calculator.tab_ai_tour),
                _tab(ref, theme, HomeTab.converter, Assets.svg.icTabConverter, t.calculator.tab_converter),
                _tab(ref, theme, HomeTab.calculator, Assets.svg.icTabCalculator, t.calculator.tab_calculator),
                _tab(ref, theme, HomeTab.settings, Assets.svg.icTabSetting, t.calculator.tab_settings),
              ],
            ),
          );
  }

  Widget _tab(WidgetRef ref, MenuTabsGroup theme, HomeTab tab, SvgGenImage svgIcon, String label) {
    final activeTab = ref.watch(navigationControllerProvider);
    final active = activeTab == tab;
    final color = active ? theme.tabActive : theme.tabInactive;
    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeOutCubic;

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => ref.read(navigationControllerProvider.notifier).setTab(tab),
          borderRadius: BorderRadius.circular(AppDimens.gap6),
          splashColor: theme.tabActive.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: SizedBox(
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPadding(
                  duration: duration,
                  curve: curve,
                  padding: EdgeInsets.only(top: active ? 0 : 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: active ? 1.2 : 1.0,
                        duration: duration,
                        curve: curve,
                        child: svgIcon.svg(colorFilter: ColorFilter.mode(color, BlendMode.srcIn), width: 22, height: 22),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: duration,
                        curve: curve,
                        style: (active ? AppTextStyles.navTabActive : AppTextStyles.navTabInactive).copyWith(color: color),
                        child: Text(label),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
