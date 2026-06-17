import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------- Brand ----------
  /// Cam san hô (Splash, Dialogs, Equals, Active Tab)
  static const Color brandOrange = Color(0xFFF5914E);

  /// Alias cho brandOrange dùng trong Theme
  static const Color accentOrange = brandOrange;

  // ---------- Surface ----------
  /// Nền tối (Menu bar, Display outer)
  static const Color surfaceDark = Color(0xFF323232);

  /// Nền LCD (Display inner)
  static const Color surfaceLCD = Color(0xFFCEE3E5);

  /// Nền trắng
  static const Color surfaceWhite = Colors.white;

  /// Nền tab Settings
  static const Color settingsBg = Color(0xFFB8B8B8);

  // ---------- Text ----------
  /// Chữ chính trên màn hình LCD
  static const Color textPrimary = Color(0xFF111111);

  /// Chữ phụ / history
  static const Color textSecondary = Color(0xFF555555);

  /// Chữ trên màn hình LCD (Kết quả preview)
  static const Color textResultPreview = Color(0xFF444444);

  /// Chữ trên nền tối (Buttons)
  static const Color textOnDark = Colors.white;

  /// Chữ trên nút sáng (digit)
  static const Color textOnButton = Color(0xFF2E2E2E);

  /// Chữ lỗi
  static const Color textError = Color(0xFFC62828);

  // ---------- Button variants (Matching Image) ----------
  /// Nền nút digit (0–9, dấu phẩy, 00) - Charcoal
  static const Color buttonDigitBg = Color(0xFF37344A);

  /// Nền nút function (√, ^, X², undo, ±, %, 1/x, ⌫, ( )) - Teal Grey
  static const Color buttonFunctionBg = Color(0xFF416973);

  /// Nền nút operator (+ − × ÷) - Slate Blue
  static const Color buttonOperatorBg = Color(0xFF697387);

  /// Nền nút clear (C) - Dark Red
  static const Color buttonClearBg = Color(0xFF8F3D52);

  /// Nền nút equals (=) - Bright Orange
  static const Color buttonEqualsBg = brandOrange;

  // ---------- Metallic Background ----------
  static const Color metallicLight = Color(0xFFE0E0E0);
  static const Color metallicDark = Color(0xFFBDBDBD);

  // ---------- Others ----------
  static const Color charcoalGray = Color(0xFF393939);
}
