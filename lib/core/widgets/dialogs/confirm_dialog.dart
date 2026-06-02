import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/widgets/dialogs/app_dialog.dart';
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
  }) {
    final loc = MaterialLocalizations.of(context);
    final confirmLabel = confirmText ?? loc.okButtonLabel;
    final cancelLabel = cancelText ?? loc.cancelButtonLabel;
    final confirmColor = destructive ? AppColors.textError : AppColors.brandOrange;

    return AppDialog.show<bool>(
      context: context,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}