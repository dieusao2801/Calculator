part of '../app_theme_ext.dart';

/// Helpers nội bộ cho các `lerp` của sub-group — private cho library
/// `app_theme_ext.dart`, không expose ra ngoài.
Color _lerpColor(Color a, Color b, double t) => Color.lerp(a, b, t) ?? b;

/*
  Chức năng: Snap value tại `t = 0.5` cho field không lerp được (bool, enum,
  ImageProvider). Dùng khi không có cách interpolate ngữ nghĩa.
  Gọi tại: `AppThemeExt.lerp`, `LayoutFlags.lerp`, `BackgroundGroup.lerp` (homeImage).
*/
T _snap<T>(T a, T b, double t) => t < 0.5 ? a : b;
