import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/home/presentation/widgets/home_background.dart';
import 'package:calculator/features/home/presentation/widgets/home_tab_pager.dart';
import 'package:calculator/features/home/presentation/widgets/menu_tabs.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomeBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: AppDimens.gap12),
              const Expanded(child: HomeTabPager()),
              const SizedBox(height: AppDimens.gap4),
              const MenuTabs(),
              const SizedBox(height: AppDimens.gap8),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
