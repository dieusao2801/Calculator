import 'package:flutter/material.dart';

/// Các text style dùng chung.
class AppTextStyles {
  AppTextStyles._();

  /// Title splash.
  static const TextStyle splashAppName = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2);

  /// Loading text splash.
  static const TextStyle splashLoading = TextStyle(fontSize: 18, fontWeight: FontWeight.w400);

  /// Expression chính trong display (auto-fit từ 40 → 20).
  static const TextStyle displayExpression = TextStyle(fontSize: 40, fontWeight: FontWeight.w500);

  /// Kết quả trong display (auto-fit từ 32 → 18).
  static const TextStyle displayResult = TextStyle(fontSize: 32, fontWeight: FontWeight.w400);

  /// History row (lịch sử biểu thức trước).
  static const TextStyle displayHistory = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  /// Label nút calculator.
  static const TextStyle calcButtonLabel = TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 0.9);

  /// Label tab dưới đáy (active).
  static const TextStyle menuTabActive = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

  /// Label tab dưới đáy (inactive).
  static const TextStyle menuTabInactive = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
}
