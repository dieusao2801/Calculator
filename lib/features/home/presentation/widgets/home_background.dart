import 'package:calculator/core/router/home_tab.dart';
import 'package:calculator/core/router/navigation_provider.dart';
import 'package:calculator/core/theme/app_theme_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeBackground extends ConsumerWidget {
  const HomeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(navigationControllerProvider);
    final theme = context.appTheme.background;
    final useSolid = activeTab == HomeTab.settings;

    final key = ValueKey('${useSolid ? 'solid' : 'image'}_${theme.homeImage.hashCode}');

    final backgroundWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: key,
        decoration: BoxDecoration(
          color: useSolid ? theme.settingsSolid : null,
          image: useSolid
              ? null
              : DecorationImage(
                  image: theme.homeImage,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low, // Tăng tốc độ render
                ),
        ),
      ),
    );

    return Stack(
      children: [
        Positioned.fill(child: backgroundWidget),
        Positioned.fill(child: RepaintBoundary(child: child)),
      ],
    );
  }
}
