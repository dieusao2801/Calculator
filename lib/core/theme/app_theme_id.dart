import 'package:flutter/material.dart';

/// Phân loại Theme để hiển thị trong UI Settings.
enum ThemeCategory {
  classic('Classic'),
  modern('Modern'),
  special('Special');

  final String displayName;
  const ThemeCategory(this.displayName);
}

/// Định danh từng theme variant của app.
///
/// `primaryColor` dùng cho:
/// - Preview thumbnail trong UI chọn theme.
/// - Seed color cho `ColorScheme.fromSeed`.
enum AppThemeId {
  // ---------- Classic (6) ----------
  classic(ThemeCategory.classic, 'Classic Grey', Color(0xFFFF9534)),
  classicBlue(ThemeCategory.classic, 'Classic Blue', Color(0xFF4A6E7A)),
  classicGreen(ThemeCategory.classic, 'Classic Green', Color(0xFFE5C7B0)),
  classicPurple(ThemeCategory.classic, 'Classic Purple', Color(0xFF7E57C2)),
  classicOrange(ThemeCategory.classic, 'Classic Orange', Color(0xFFFF9534)),
  classicDark(ThemeCategory.classic, 'Classic Dark', Color(0xFFB0AEA0)),

  // ---------- Modern (6) ----------
  modernDark(ThemeCategory.modern, 'Modern Dark', Color(0xFFFF9534)),
  modernLight(ThemeCategory.modern, 'Modern Light', Color(0xFFFFB300)),
  modernPurple(ThemeCategory.modern, 'Modern Purple', Color(0xFF8E24AA)),
  modernGreen(ThemeCategory.modern, 'Modern Green', Color(0xFF66BB6A)),
  modernBlue(ThemeCategory.modern, 'Modern Blue', Color(0xFF4E92FF)),
  modernRed(ThemeCategory.modern, 'Modern Red', Color(0xFFE94B6A));

  // TODO(special-themes): thêm Special Aries (Zodiac) khi có asset background.

  final ThemeCategory category;
  final String displayName;
  final Color primaryColor;

  const AppThemeId(this.category, this.displayName, this.primaryColor);

  /*
    Chức năng: Khôi phục [AppThemeId] từ string đã persist trong SharedPreferences.
    Fallback về `classic` khi `raw == null` hoặc không khớp tên enum nào — xảy ra
    khi theme cũ bị xóa (vd: `specialOcean`, `specialAries`, `specialGalaxy`).
    Gọi tại: `theme_manager.dart` → `ThemeManager.build()`.
  */
  static AppThemeId fromStorage(String? raw) =>
      raw == null ? classic : (values.asNameMap()[raw] ?? classic);

  /*
    Chức năng: Lọc danh sách theme thuộc một [category].
    Gọi tại: `theme_selector_section.dart` — render section Classic / Modern.
  */
  static List<AppThemeId> byCategory(ThemeCategory category) =>
      values.where((t) => t.category == category).toList(growable: false);
}