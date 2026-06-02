part of '../app_theme_ext.dart';

/// Token cho bottom MenuTabs — màu nền tab bar và màu tab active/inactive.
@immutable
class MenuTabsGroup {
  const MenuTabsGroup({required this.bg, required this.tabActive, required this.tabInactive});

  final Color bg;
  final Color tabActive;
  final Color tabInactive;

  MenuTabsGroup copyWith({Color? bg, Color? tabActive, Color? tabInactive}) => MenuTabsGroup(
    bg: bg ?? this.bg,
    tabActive: tabActive ?? this.tabActive,
    tabInactive: tabInactive ?? this.tabInactive,
  );

  static MenuTabsGroup lerp(MenuTabsGroup a, MenuTabsGroup b, double t) => MenuTabsGroup(
    bg: _lerpColor(a.bg, b.bg, t),
    tabActive: _lerpColor(a.tabActive, b.tabActive, t),
    tabInactive: _lerpColor(a.tabInactive, b.tabInactive, t),
  );
}