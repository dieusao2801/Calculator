import 'package:flutter/material.dart';

class AppStyles {
  AppStyles._();

  /// Divider chung cho toàn app để tránh phân mảnh code.
  static Widget divider({double height = 1, double thickness = 1}) {
    return Divider(height: height, thickness: thickness, color: Colors.black.withValues(alpha: 0.15));
  }

  // Bạn có thể thêm các style khác như BoxDecoration, InputDecoration vào đây.
}
