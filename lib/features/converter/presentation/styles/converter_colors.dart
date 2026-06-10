import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/features/converter/domain/converter_item.dart';
import 'package:flutter/material.dart';

// TODO(theming-v2): chuyển toàn bộ const dưới sang ThemeExtension khi triển khai 24 themes.
class ConverterColors {
  ConverterColors._();

  // Text
  static const Color title = Color(0xFF333333);
  static const Color subtitle = Color(0xFF666666);
  static const Color label = Color(0xFF444444);

  // Search bar
  static const Color searchBorder = Color(0xFF999999);
  static const Color searchIcon = Color(0xFF666666);
  static const Color searchText = Color(0xFF333333);
  static const Color searchBg = Color(0xFFF2F2F2);

  // Empty state
  static const Color noResults = Color(0xFF696969);

  // FAB gradient
  static const Color fabGradientTop = Color(0xFFFF9053);
  static const Color fabGradientMid = Color(0xFFFF9255);
  static const Color fabGradientBottom = Color(0xFFFF823D);
}

/// Cặp màu gradient cho icon tile.
class ConverterGradient {
  const ConverterGradient(this.top, this.bottom);
  final Color top;
  final Color bottom;
}

// Gradient theo enum ConverterColorTheme — khớp màu nút bấm và ảnh mockup.
const ConverterGradient kGradientBluish = ConverterGradient(AppColors.buttonOperatorBg, Color(0xFF4E5666));
const ConverterGradient kGradientLightBlue = ConverterGradient(AppColors.buttonFunctionBg, Color(0xFF2E4B52));
const ConverterGradient kGradientCoral = ConverterGradient(AppColors.buttonClearBg, Color(0xFF6B2E3D));
const ConverterGradient kGradientBeige = ConverterGradient(AppColors.buttonDigitBg, Color(0xFF262433));
const ConverterGradient kGradientLavender = ConverterGradient(Color(0xFFA4ABBE), Color(0xFF838A9C));
const ConverterGradient kGradientPurple = ConverterGradient(Color(0xFF564860), Color(0xFF3D3045));
const ConverterGradient kGradientTealLight = ConverterGradient(Color(0xFF5F8A8F), Color(0xFF436A6F));

extension ConverterColorThemeGradient on ConverterColorTheme {
  ConverterGradient get gradient {
    switch (this) {
      case ConverterColorTheme.bluish:
        return kGradientBluish;
      case ConverterColorTheme.lightBlue:
        return kGradientLightBlue;
      case ConverterColorTheme.coral:
        return kGradientCoral;
      case ConverterColorTheme.beige:
        return kGradientBeige;
      case ConverterColorTheme.lavender:
        return kGradientLavender;
      case ConverterColorTheme.purple:
        return kGradientPurple;
      case ConverterColorTheme.tealLight:
        return kGradientTealLight;
    }
  }
}
