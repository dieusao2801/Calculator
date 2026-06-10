import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/converter/presentation/styles/converter_colors.dart';
import 'package:flutter/material.dart';

/// Section trong Converter tab: title 22/Bold màu đen + child.
class ConverterSectionWidget extends StatelessWidget {
  const ConverterSectionWidget({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ConverterColors.title, letterSpacing: 0.5),
        ),
        const SizedBox(height: AppDimens.gap12),
        child,
      ],
    );
  }
}
