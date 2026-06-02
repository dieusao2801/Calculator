import 'package:calculator/features/calculator/presentation/widgets/calc_button.dart';
import 'package:flutter/material.dart';

part 'ext/_lerp.dart';
part 'ext/layout_flags.dart';
part 'ext/calc_button.dart';
part 'ext/display_panel.dart';
part 'ext/menu_tabs.dart';
part 'ext/background.dart';

/// Root [ThemeExtension] gom toàn bộ token theo theme — gắn vào
/// [ThemeData.extensions]. Truy cập gọn qua `context.appTheme`.
///
/// Các sub-group được tách ra thành part files trong folder `ext/` để dễ quản lý.
@immutable
class AppThemeExt extends ThemeExtension<AppThemeExt> {
  const AppThemeExt({
    required this.button,
    required this.display,
    required this.menu,
    required this.background,
    required this.layout,
  });

  final CalcButtonGroup button;
  final DisplayPanelGroup display;
  final MenuTabsGroup menu;
  final BackgroundGroup background;
  final LayoutFlags layout;

  @override
  AppThemeExt copyWith({
    CalcButtonGroup? button,
    DisplayPanelGroup? display,
    MenuTabsGroup? menu,
    BackgroundGroup? background,
    LayoutFlags? layout,
  }) => AppThemeExt(
    button: button ?? this.button,
    display: display ?? this.display,
    menu: menu ?? this.menu,
    background: background ?? this.background,
    layout: layout ?? this.layout,
  );

  /*
    Chức năng: Interpolate giữa 2 theme khi Flutter animate theme transition.
    Field lerp được (Color) thì blend; field không lerp được (bool, enum,
    ImageProvider) snap tại `t = 0.5` qua helper `_snap`.
    Gọi tại: Flutter framework tự động khi `MaterialApp.theme` đổi.
  */
  @override
  AppThemeExt lerp(ThemeExtension<AppThemeExt>? other, double t) {
    if (other is! AppThemeExt) return this;
    return AppThemeExt(
      button: CalcButtonGroup.lerp(button, other.button, t),
      display: DisplayPanelGroup.lerp(display, other.display, t),
      menu: MenuTabsGroup.lerp(menu, other.menu, t),
      background: BackgroundGroup.lerp(background, other.background, t),
      layout: LayoutFlags.lerp(layout, other.layout, t),
    );
  }
}

extension AppThemeContext on BuildContext {
  /*
    Chức năng: Sugar truy cập [AppThemeExt] đang active. Non-null vì
    `AppTheme.fromId` luôn đăng ký extension vào `ThemeData`.
    Gọi tại: `calc_button.dart`, `display_panel.dart`, `menu_tabs.dart`,
    `home_background.dart` — đọc token màu/layout theo theme.
  */
  AppThemeExt get appTheme => Theme.of(this).extension<AppThemeExt>()!;
}
