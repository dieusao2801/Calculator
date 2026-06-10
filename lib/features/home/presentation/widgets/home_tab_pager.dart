import 'package:calculator/core/router/home_tab.dart';
import 'package:calculator/core/router/navigation_provider.dart';
import 'package:calculator/features/ai_tour/presentation/pages/ai_tour_tab.dart';
import 'package:calculator/features/calculator/presentation/pages/calculator_tab.dart';
import 'package:calculator/features/converter/presentation/pages/converter_tab.dart';
import 'package:calculator/features/settings/presentation/pages/settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PageView swipe được + giữ state qua [_KeepAlive] wrapper.
///
/// Sync 2 chiều giữa [PageController] và [NavigationController]:
/// - Tap MenuTabs → controller setTab(tab) → useEffect jumpToPage.
/// - Swipe → onPageChanged → setTab.
/// - Dùng cờ guard để tránh loop infinite.
class HomeTabPager extends ConsumerStatefulWidget {
  const HomeTabPager({super.key});

  @override
  ConsumerState<HomeTabPager> createState() => _HomeTabPagerState();
}

class _HomeTabPagerState extends ConsumerState<HomeTabPager> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(navigationControllerProvider);
    _pageController = PageController(initialPage: initial.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe state đổi từ MenuTabs → chuyển PageView.
    ref.listen<HomeTab>(navigationControllerProvider, (prev, next) {
      // Ẩn bàn phím khi đổi tab (vd Search trong Converter, chat input AI Tutor).
      FocusManager.instance.primaryFocus?.unfocus();
      if (_pageController.hasClients) {
        // Chỉ chuyển trang nếu vị trí hiện tại khác với vị trí được chọn
        final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
        if (currentPage != next.index) {
          _pageController.animateToPage(
            next.index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });

    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        // Cập nhật State khi user swipe (nếu index khác với state hiện tại).
        // Việc unfocus bàn phím do `ref.listen` ở trên đảm nhiệm khi state đổi.
        final currentTab = ref.read(navigationControllerProvider);
        if (currentTab.index != index) {
          ref.read(navigationControllerProvider.notifier).setTab(HomeTab.fromIndex(index));
        }
      },
      children: const [
        _KeepAlive(child: RepaintBoundary(child: AiTourTab())),
        _KeepAlive(child: RepaintBoundary(child: ConverterTab())),
        _KeepAlive(child: RepaintBoundary(child: CalculatorTab())),
        _KeepAlive(child: RepaintBoundary(child: SettingsTab())),
      ],
    );
  }
}

/// Wrap mỗi tab để PageView giữ state.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
