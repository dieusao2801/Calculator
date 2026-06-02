import 'package:calculator/core/theme/app_theme_id.dart';
import 'package:calculator/core/theme/app_themes.dart';
import 'package:flutter/material.dart';

/// Builder cho [ThemeData] toàn app — gắn [AppThemeExt] vào ThemeData để widget
/// truy cập token qua `context.appTheme`.
class AppTheme {
  AppTheme._();

  /*
    Chức năng: Dựng [ThemeData] hoàn chỉnh theo [id] — gồm ColorScheme từ seed,
    scaffold background lấy từ display.bgOuter, và đăng ký [AppThemeExt] làm
    ThemeExtension.
    Brightness rule: `classic.*` + `modernLight` → light; các theme khác → dark.
    Gọi tại: `main.dart` (MaterialApp.theme) mỗi khi `themeManagerProvider` đổi.
  */
  static ThemeData fromId(AppThemeId id) {
    final ext = AppThemes.of(id);
    final brightness = (id.category == ThemeCategory.classic || id == AppThemeId.modernLight)
        ? Brightness.light
        : Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: id.primaryColor, brightness: brightness),
      scaffoldBackgroundColor: ext.display.bgOuter,
      extensions: [ext],
    );
  }
}