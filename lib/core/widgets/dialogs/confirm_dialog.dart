import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Template dialog xác nhận Yes/No.
///
/// Trả về `true` nếu nhấn nút confirm, `false` nếu nhấn cancel,
/// `null` nếu dismiss (tap ngoài / back).
///
/// Text mặc định fallback về [MaterialLocalizations] (đa ngôn ngữ built-in
/// của Flutter — không cần i18n key riêng).
class ConfirmDialog {
  ConfirmDialog._();

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool destructive = false,
    bool barrierDismissible = true,
    VoidCallback? onPositive,
  }) {
    final loc = MaterialLocalizations.of(context);
    final confirmLabel = confirmText ?? loc.okButtonLabel;
    final cancelLabel = cancelText ?? loc.cancelButtonLabel;
    final confirmColor = destructive ? AppColors.textError : AppColors.textPrimary;

    return AppBaseDialog.show<bool>(
      context: context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      actions: [
        TextButton(
          onPressed: () => context.maybePop(false),
          child: Text(cancelLabel.toUpperCase(), style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
        ),
        TextButton(
          onPressed: () {
            onPositive?.call();
            context.maybePop(true);
          },
          child: Text(confirmLabel.toUpperCase(), style: AppTextStyles.labelLarge.copyWith(color: confirmColor)),
        ),
      ],
    );
  }
}
