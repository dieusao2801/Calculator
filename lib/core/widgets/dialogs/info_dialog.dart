import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Template dialog thông báo 1 nút OK.
///
/// Trả về `true` nếu nhấn OK, `null` nếu dismiss.
class InfoDialog {
  InfoDialog._();

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String? buttonText,
    bool barrierDismissible = true,
  }) {
    final loc = MaterialLocalizations.of(context);
    final label = buttonText ?? loc.okButtonLabel;

    return AppBaseDialog.show<bool>(
      context: context,
      title: title,
      message: message,
      content: content,
      barrierDismissible: barrierDismissible,
      actions: [
        TextButton(
          onPressed: () => context.maybePop(true),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(color: AppColors.brandOrange, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
