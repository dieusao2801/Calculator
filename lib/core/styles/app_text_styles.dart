import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Quản lý tập trung các Text Style của ứng dụng.
/// Các style được chia thành 2 nhóm: Nhóm đặc thù (Feature-specific) và Nhóm dùng chung (Common/Role-based).
class AppTextStyles {
  AppTextStyles._();

  // ===========================================================================
  // 1. NHÓM ĐẶC THỦ (FEATURE-SPECIFIC)
  // ===========================================================================

  // --- SPLASH SCREEN ---
  static const TextStyle splashAppName = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    color: AppColors.textPrimary,
  );
  static const TextStyle splashLoading = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  // --- CALCULATOR FEATURE ---

  /// Biểu thức chính đang nhập (Dòng trên - lớn nhất).
  /// Thường dùng auto-fit từ 40 → 20.
  static const TextStyle calculatorExpression = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Kết quả xem trước hoặc kết quả cuối (Dòng dưới - nhỏ hơn).
  /// Thường dùng auto-fit từ 32 → 18.
  static const TextStyle calculatorPreview = TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  /// Dòng lịch sử biểu thức cũ phía trên cùng.
  static const TextStyle calculatorHistory = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  /// Nhãn trên các nút bấm máy tính (0-9, +, -, x, /).
  static const TextStyle calculatorKeyLabel = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 0.9,
    color: AppColors.textPrimary,
  );

  // --- NAVIGATION ---
  static const TextStyle navTabActive = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static const TextStyle navTabInactive = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  // ===========================================================================
  // 2. NHÓM DÙNG CHUNG (COMMON / ROLE-BASED)
  // Dựa trên Material 3 scale - dùng cho Settings, Dialogs, Lists, v.v.
  // ===========================================================================

  /// Headline lớn — screen title placeholder, big screen header.
  static const TextStyle headlineLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  /// Headline nhỏ (20px) — section header, sub-screen title.
  static const TextStyle headlineSmall = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  /// Tiêu đề lớn — dialog title.
  static const TextStyle titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  /// Tiêu đề trung — sheet header, sub-screen header, empty state title.
  static const TextStyle titleMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  /// Tiêu đề nhỏ — card title, list item title, picker header, history result emphasis.
  static const TextStyle titleSmall = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  /// Body lớn — paragraph chính, dialog body, note text, input field.
  static const TextStyle bodyLarge = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  /// Body trung — secondary text, toast, timestamp, dialog date.
  static const TextStyle bodyMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  /// Body nhỏ — caption phụ trợ, footer text, app version.
  static const TextStyle bodySmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  /// Label lớn (16px) — Dùng cho Button chính, Tab bar, Section header nhỏ.
  static const TextStyle labelLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  /// Label trung (14px) — Dùng cho Secondary Button, Badge, Tag, Filter chip.
  static const TextStyle labelMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  /// Label nhỏ (12px) — Dùng cho nhãn phụ cực nhỏ, App version, Caption bổ trợ.
  static const TextStyle labelSmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
}
