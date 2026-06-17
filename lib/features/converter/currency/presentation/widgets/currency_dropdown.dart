import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/widgets/marquee_text.dart';
import 'package:flutter/material.dart';

class CurrencyDropdown extends StatelessWidget {
  const CurrencyDropdown({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4A4A4A), width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: MarqueeText(label, style: AppTextStyles.bodyMedium),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF333333), size: 28),
          ],
        ),
      ),
    );
  }
}
