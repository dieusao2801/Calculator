import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/theme/app_theme_ext.dart';
import 'package:calculator/core/theme/app_theme_id.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// Dữ liệu color/flags layout cho từng [AppThemeId].
///
/// Pattern: 2 base private (`_classic`, `_modern`) cho 2 nhóm, mỗi variant
/// chỉ override điểm khác biệt qua `copyWith` để tránh lặp.
class AppThemes {
  AppThemes._();

  /*
    Chức năng: Lấy [AppThemeExt] tương ứng với theme [id].
    Switch exhaustive — compile-time error nếu thêm AppThemeId mới mà quên
    cập nhật ở đây.
    Gọi tại: `app_theme.dart` → `AppTheme.fromId()`.
  */
  static AppThemeExt of(AppThemeId id) => switch (id) {
    AppThemeId.classic => _classic,
    AppThemeId.classicBlue => _classicBlue,
    AppThemeId.classicGreen => _classicGreen,
    AppThemeId.classicPurple => _classicPurple,
    AppThemeId.classicOrange => _classicOrange,
    AppThemeId.classicDark => _classicDark,
    AppThemeId.modernDark => _modern,
    AppThemeId.modernLight => _modernLight,
    AppThemeId.modernPurple => _modernPurple,
    AppThemeId.modernGreen => _modernGreen,
    AppThemeId.modernBlue => _modernBlue,
    AppThemeId.modernRed => _modernRed,
  };

  // ==========================================================================
  // BASE: Classic — bottom MenuTabs, display LCD xanh nhạt, button rounded rect.
  // ==========================================================================
  static final AppThemeExt _classic = AppThemeExt(
    button: CalcButtonGroup(
      digit: (bg: AppColors.buttonDigitBg, fg: AppColors.textOnDark, bgImage: null),
      operator: (bg: AppColors.buttonOperatorBg, fg: AppColors.textOnDark, bgImage: null),
      function: (bg: AppColors.buttonFunctionBg, fg: AppColors.textOnDark, bgImage: null),
      delete: (bg: AppColors.buttonFunctionBg, fg: AppColors.textOnDark, bgImage: null),
      clear: (bg: AppColors.buttonClearBg, fg: AppColors.textOnDark, bgImage: null),
      equals: (bg: AppColors.buttonEqualsBg, fg: AppColors.textOnDark, bgImage: null),
    ),
    display: const DisplayPanelGroup(
      bgOuter: Color(0XFF3C3C3C),
      bgInner: AppColors.surfaceLCD,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textError: AppColors.textError,
    ),
    menu: const MenuTabsGroup(
      bg: AppColors.surfaceDark,
      tabActive: AppColors.accentOrange,
      tabInactive: Color(0xFFE0E0E0),
    ),
    background: BackgroundGroup(
      homeImage: Assets.images.bgBackgroundClassic.provider(),
      settingsSolid: AppColors.settingsBg,
    ),
    layout: const LayoutFlags(hasMenuTabs: true, hasTopAppBar: false, useBackgroundImage: false),
  );

  static final AppThemeExt _classicBlue = _classic.copyWith(
    button: _classic.button.copyWith(
      function: (bg: const Color(0xFF2F4A55), fg: AppColors.textOnDark, bgImage: null),
      operator: (bg: const Color(0xFF2F4A55), fg: AppColors.textOnDark, bgImage: null),
      digit: (bg: const Color(0xFF4A5C66), fg: AppColors.textOnDark, bgImage: null),
      delete: (bg: const Color(0xFF2F4A55), fg: AppColors.textOnDark, bgImage: null),
    ),
    menu: _classic.menu.copyWith(tabActive: const Color(0xFF2F4A55)),
  );

  static final AppThemeExt _classicGreen = _classic.copyWith(
    button: const CalcButtonGroup(
      digit: (bg: Color(0xFFFFFFFF), fg: AppColors.textOnButton, bgImage: null),
      operator: (bg: Color(0xFF4A6E7A), fg: AppColors.textOnDark, bgImage: null),
      function: (bg: Color(0xFFC7DDE3), fg: Color(0xFF1D3557), bgImage: null),
      delete: (bg: Color(0xFFC7DDE3), fg: Color(0xFF1D3557), bgImage: null),
      clear: (bg: Color(0xFFFFC5BB), fg: Color(0xFFC85A5A), bgImage: null),
      equals: (bg: Color(0xFFFFB199), fg: Color(0xFFC85A5A), bgImage: null),
    ),
    display: const DisplayPanelGroup(
      bgOuter: Color(0xFFE5E5E5),
      bgInner: Color(0xFFE8F2F3),
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textError: AppColors.textError,
    ),
    menu: const MenuTabsGroup(
      bg: Color(0xFFE5E5E5),
      tabActive: Color(0xFFFFB199),
      tabInactive: AppColors.textPrimary,
    ),
    background: BackgroundGroup(
      homeImage: Assets.images.bgBackgroundClassic.provider(),
      settingsSolid: const Color(0xFFE5E5E5),
    ),
  );

  static final AppThemeExt _classicPurple = _classic.copyWith(
    button: _classic.button.copyWith(
      digit: (bg: const Color(0xFF2A2A2A), fg: AppColors.textOnDark, bgImage: null),
      function: (bg: const Color(0xFF7E57C2), fg: AppColors.textOnDark, bgImage: null),
      operator: (bg: const Color(0xFF7E57C2), fg: AppColors.textOnDark, bgImage: null),
      delete: (bg: const Color(0xFF7E57C2), fg: AppColors.textOnDark, bgImage: null),
      clear: (bg: const Color(0xFFE94B4B), fg: AppColors.textOnDark, bgImage: null),
      equals: (bg: const Color(0xFFFFB300), fg: AppColors.textOnDark, bgImage: null),
    ),
    menu: _classic.menu.copyWith(tabActive: const Color(0xFFFFB300)),
  );

  static final AppThemeExt _classicOrange = _classic.copyWith(
    button: _classic.button.copyWith(
      operator: (bg: const Color(0xFF6B7F86), fg: AppColors.textOnDark, bgImage: null),
      function: (bg: const Color(0xFF6B7F86), fg: AppColors.textOnDark, bgImage: null),
      delete: (bg: const Color(0xFF6B7F86), fg: AppColors.textOnDark, bgImage: null),
      clear: (bg: const Color(0xFFC85A5A), fg: AppColors.textOnDark, bgImage: null),
      equals: (bg: const Color(0xFFFF7A1F), fg: AppColors.textOnDark, bgImage: null),
    ),
    menu: _classic.menu.copyWith(tabActive: const Color(0xFFFF7A1F)),
  );

  static final AppThemeExt _classicDark = _classic.copyWith(
    button: _classic.button.copyWith(
      digit: (bg: const Color(0xFFC5C5BC), fg: AppColors.textOnButton, bgImage: null),
      function: (bg: const Color(0xFF8E948C), fg: AppColors.textOnDark, bgImage: null),
      operator: (bg: const Color(0xFF8E948C), fg: AppColors.textOnDark, bgImage: null),
      delete: (bg: const Color(0xFF8E948C), fg: AppColors.textOnDark, bgImage: null),
      clear: (bg: const Color(0xFFB85555), fg: AppColors.textOnDark, bgImage: null),
      equals: (bg: const Color(0xFFFF8534), fg: AppColors.textOnDark, bgImage: null),
    ),
    display: _classic.display.copyWith(bgOuter: const Color(0xFFB0AEA0)),
    background: BackgroundGroup(
      homeImage: Assets.images.bgBackgroundClassic.provider(),
      settingsSolid: const Color(0xFFB0AEA0),
    ),
  );

  // ==========================================================================
  // BASE: Modern — top AppBar, display flat, button rounded rect flat.
  // ==========================================================================
  static final AppThemeExt _modern = AppThemeExt(
    button: const CalcButtonGroup(
      digit: (bg: Color(0xFF1A2333), fg: AppColors.textOnDark, bgImage: null),
      operator: (bg: Color(0xFFFF9534), fg: AppColors.textOnDark, bgImage: null),
      function: (bg: Color(0xFF243144), fg: AppColors.textOnDark, bgImage: null),
      delete: (bg: Color(0xFF243144), fg: AppColors.textOnDark, bgImage: null),
      clear: (bg: Color(0xFFE94B6A), fg: AppColors.textOnDark, bgImage: null),
      equals: (bg: Color(0xFFFF9534), fg: AppColors.textOnDark, bgImage: null),
    ),
    display: const DisplayPanelGroup(
      bgOuter: Color(0xFF0F1A2A),
      bgInner: Color(0xFF0F1A2A),
      textPrimary: AppColors.textOnDark,
      textSecondary: Color(0xFF9E9E9E),
      textError: Color(0xFFFF6B6B),
    ),
    menu: const MenuTabsGroup(
      bg: Color(0xFF0F1A2A),
      tabActive: Color(0xFFFF9534),
      tabInactive: Color(0xFF9E9E9E),
    ),
    background: BackgroundGroup(
      homeImage: Assets.images.bgBackgroundClassic.provider(),
      settingsSolid: const Color(0xFF0F1A2A),
    ),
    layout: const LayoutFlags(hasMenuTabs: false, hasTopAppBar: true, useBackgroundImage: false),
  );

  static final AppThemeExt _modernLight = _modern.copyWith(
    button: const CalcButtonGroup(
      digit: (bg: Color(0xFFFFFFFF), fg: AppColors.textOnButton, bgImage: null),
      operator: (bg: Color(0xFFFFB300), fg: AppColors.textOnDark, bgImage: null),
      function: (bg: Color(0xFFF8E9C5), fg: AppColors.textOnButton, bgImage: null),
      delete: (bg: Color(0xFFF8E9C5), fg: AppColors.textOnButton, bgImage: null),
      clear: (bg: Color(0xFFFFB6B6), fg: Color(0xFFC85A5A), bgImage: null),
      equals: (bg: Color(0xFFFFB300), fg: AppColors.textOnDark, bgImage: null),
    ),
    display: const DisplayPanelGroup(
      bgOuter: Color(0xFFFFFFFF),
      bgInner: Color(0xFFF5F5F5),
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textError: AppColors.textError,
    ),
    menu: const MenuTabsGroup(
      bg: Color(0xFFFFFFFF),
      tabActive: Color(0xFFFFB300),
      tabInactive: AppColors.textSecondary,
    ),
    background: BackgroundGroup(
      homeImage: Assets.images.bgBackgroundClassic.provider(),
      settingsSolid: const Color(0xFFFFFFFF),
    ),
  );

  /*
    Chức năng: Helper dựng modern variant chỉ khác base ở 1 màu accent (operator
    + tab active) và 1 màu bgOuter (display + settings).
    Gọi tại: 4 variant modern: Purple / Green / Blue / Red bên dưới.
  */
  static AppThemeExt _modernAccent({required Color accent, required Color bgOuter}) =>
      _modern.copyWith(
        button: _modern.button.copyWith(
          operator: (bg: accent, fg: AppColors.textOnDark, bgImage: null),
        ),
        display: _modern.display.copyWith(bgOuter: bgOuter),
        menu: _modern.menu.copyWith(tabActive: accent),
        background: _modern.background.copyWith(settingsSolid: bgOuter),
      );

  static final AppThemeExt _modernPurple = _modernAccent(
    accent: const Color(0xFF8E24AA),
    bgOuter: const Color(0xFF2D2A4A),
  );
  static final AppThemeExt _modernGreen = _modernAccent(
    accent: const Color(0xFF66BB6A),
    bgOuter: const Color(0xFF1A2A1A),
  );
  static final AppThemeExt _modernBlue = _modernAccent(
    accent: const Color(0xFF4E92FF),
    bgOuter: const Color(0xFF0F1A2E),
  );
  static final AppThemeExt _modernRed = _modernAccent(
    accent: const Color(0xFFE94B6A),
    bgOuter: const Color(0xFF2A0F1A),
  );

  // TODO(special-themes): bổ sung Special Aries khi có asset Zodiac.
}
