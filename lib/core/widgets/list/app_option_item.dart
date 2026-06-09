import 'package:calculator/core/styles/app_styles.dart';
import 'package:flutter/material.dart';

/// Một widget item tùy chọn chuẩn cho các Dialog hoặc Menu.
/// Bao gồm Icon, Label và đường kẻ Divider tự động.
class AppOptionItem extends StatelessWidget {
  const AppOptionItem({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.iconSize = 24,
    this.fontSize = 15,
    this.iconColor = Colors.black87,
    this.textColor = Colors.black87,
  });

  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  final double iconSize;
  final double fontSize;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: customIcon ?? (icon != null ? Icon(icon!, size: iconSize, color: iconColor) : const SizedBox.shrink()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: fontSize, color: textColor, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) AppStyles.divider(thickness: 0.5),
      ],
    );
  }
}
