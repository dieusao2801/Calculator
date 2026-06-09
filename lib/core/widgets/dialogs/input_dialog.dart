import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:flutter/material.dart';

/// Dialog hỗ trợ nhập liệu văn bản.
/// Trả về chuỗi String nếu nhấn Confirm, null nếu nhấn Cancel hoặc dismiss.
class InputDialog {
  InputDialog._();

  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? message,
    String? initialValue,
    String? hintText,
    String? confirmText,
    String? cancelText,
    bool showUnderLine = false,
    Function(String)? onConfirm,
  }) {
    final controller = TextEditingController(text: initialValue)
      ..selection = TextSelection(baseOffset: 0, extentOffset: initialValue?.length ?? 0);
    final loc = MaterialLocalizations.of(context);

    final confirmLabel = confirmText ?? loc.okButtonLabel;
    final cancelLabel = cancelText ?? loc.cancelButtonLabel;

    return AppBaseDialog.show<String>(
      context: context,
      title: title,
      message: message,
      content: TextField(
        controller: controller,
        selectAllOnFocus: true,
        maxLength: 255,
        autofocus: true,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textSecondary),
          border: showUnderLine ? null : InputBorder.none,
          enabledBorder: showUnderLine
              ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54))
              : InputBorder.none,
          focusedBorder: showUnderLine
              ? const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.brandOrange))
              : InputBorder.none,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.maybePop(),
          child: Text(
            cancelLabel.toUpperCase(),
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm?.call(controller.text);
            context.maybePop(controller.text);
          },
          child: Text(
            confirmLabel.toUpperCase(),
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
