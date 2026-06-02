part of '../app_theme_ext.dart';

/// Token cho background của HomePage — ảnh nền (cho các tab Home) và màu nền
/// solid (cho tab Settings).
@immutable
class BackgroundGroup {
  const BackgroundGroup({required this.homeImage, required this.settingsSolid});

  /// Ảnh nền cho tab Home (Calculator/Converter/AI Tour). [ImageProvider] không
  /// lerp được nên transition sẽ snap tại `t = 0.5`.
  final ImageProvider homeImage;

  /// Màu nền solid cho tab Settings.
  final Color settingsSolid;

  BackgroundGroup copyWith({ImageProvider? homeImage, Color? settingsSolid}) => BackgroundGroup(
    homeImage: homeImage ?? this.homeImage,
    settingsSolid: settingsSolid ?? this.settingsSolid,
  );

  static BackgroundGroup lerp(BackgroundGroup a, BackgroundGroup b, double t) => BackgroundGroup(
    homeImage: _snap(a.homeImage, b.homeImage, t),
    settingsSolid: _lerpColor(a.settingsSolid, b.settingsSolid, t),
  );
}