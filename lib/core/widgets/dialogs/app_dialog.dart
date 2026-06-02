import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:flutter/material.dart';

/// Base wrapper cho mọi dialog của app.
///
/// Cung cấp skeleton thống nhất: rounded background, padding, max-width,
/// slot cho title / content / actions. KHÔNG bind feature cụ thể.
///
/// Dùng trực tiếp qua [AppDialog.show], hoặc wrap bởi template cụ thể
/// (ConfirmDialog, InfoDialog…).
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, this.title, this.message, this.content, this.actions})
    : assert(
        message != null || content != null || title != null,
        'AppDialog cần ít nhất 1 trong title / message / content',
      );

  /// Tiêu đề dialog (đậm, cỡ lớn). null = không hiển thị.
  final String? title;

  /// Text nội dung đơn giản. Bỏ qua nếu [content] được cung cấp.
  final String? message;

  /// Widget content tuỳ biến (slot). Ưu tiên hơn [message].
  final Widget? content;

  /// Các nút action ở dưới. null = không có nút.
  final List<Widget>? actions;

  /// Hiển thị dialog. Trả về kết quả T do nút action `Navigator.pop(context, value)`.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppDialog(title: title, message: message, content: content, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.gap16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.gap16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimens.gap400),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.gap20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimens.gap12),
              ],
              if (content != null)
                content!
              else if (message != null)
                Text(
                  message!,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                ),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: AppDimens.gap16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppDimens.gap8),
                      actions![i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
