part of '../app_theme_ext.dart';

/// Flags bool điều khiển layout chính của trang Calculator theo theme
/// (có MenuTabs / có AppBar / dùng background image).
@immutable
class LayoutFlags {
  const LayoutFlags({
    required this.hasMenuTabs,
    required this.hasTopAppBar,
    required this.useBackgroundImage,
  });

  final bool hasMenuTabs;
  final bool hasTopAppBar;
  final bool useBackgroundImage;

  LayoutFlags copyWith({bool? hasMenuTabs, bool? hasTopAppBar, bool? useBackgroundImage}) =>
      LayoutFlags(
        hasMenuTabs: hasMenuTabs ?? this.hasMenuTabs,
        hasTopAppBar: hasTopAppBar ?? this.hasTopAppBar,
        useBackgroundImage: useBackgroundImage ?? this.useBackgroundImage,
      );

  static LayoutFlags lerp(LayoutFlags a, LayoutFlags b, double t) => _snap(a, b, t);
}