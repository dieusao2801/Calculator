import 'package:calculator/core/router/home_tab.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class NavigationController extends _$NavigationController {
  @override
  HomeTab build() => HomeTab.calculator;

  void setTab(HomeTab tab) {
    if (state == tab) return;
    state = tab;
  }
}