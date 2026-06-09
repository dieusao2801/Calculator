import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/widgets/sheets/app_bottom_sheet.dart' show sheetSurfaceDecoration, Header;
import 'package:flutter/material.dart';

/// Base wrapper cho mọi dialog của app: rounded background, max-width,
/// slot title / content / actions. KHÔNG bind feature cụ thể.
///
/// Dùng qua [AppBaseDialog.show], hoặc wrap bởi template (ConfirmDialog, InfoDialog…).
class AppBaseDialog {
  AppBaseDialog._();

  /// Hiển thị dialog. Trả về T do nút action `Navigator.pop(context, value)`.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    List<Widget>? headerActions,
    bool showCloseButton = false,
    bool barrierDismissible = true,
    bool useBackgroundImage = true,
    ImageProvider? backgroundImage,
    Color? backgroundColor,
    Color? headerBackgroundColor,
    Color? headerForegroundColor,
  }) {
    assert(title != null || message != null || content != null, 'AppDialog cần ít nhất 1 trong title / message / content');
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,

      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _DialogView(
        title: title,
        message: message,
        content: content,
        actions: actions,
        headerActions: headerActions,
        showCloseButton: showCloseButton,
        useBackgroundImage: useBackgroundImage,
        backgroundImage: backgroundImage,
        backgroundColor: backgroundColor,
        headerBackgroundColor: headerBackgroundColor,
        headerForegroundColor: headerForegroundColor,
      ),
    );
  }
}

class _DialogView extends StatelessWidget {
  const _DialogView({
    required this.useBackgroundImage,
    required this.showCloseButton,
    this.title,
    this.message,
    this.content,
    this.actions,
    this.headerActions,
    this.backgroundImage,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.headerForegroundColor,
  });

  final String? title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final List<Widget>? headerActions;
  final bool showCloseButton;
  final bool useBackgroundImage;
  final ImageProvider? backgroundImage;
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final Color? headerForegroundColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = useBackgroundImage && backgroundColor == null;
    final fg = hasImage ? Colors.white : AppColors.textPrimary;
    final hasTitle = title != null && title!.isNotEmpty;
    final hasHeader = hasTitle || showCloseButton || (headerActions?.isNotEmpty ?? false);
    final hasActions = actions?.isNotEmpty ?? false;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.gap24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          decoration: sheetSurfaceDecoration(
            context: context,
            borderRadius: BorderRadius.circular(AppDimens.gap16),
            useBackgroundImage: useBackgroundImage,
            backgroundImage: backgroundImage,
            backgroundColor: backgroundColor,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasHeader)
                Header(
                  title: title ?? '',
                  actions: headerActions,
                  showCloseButton: showCloseButton,
                  backgroundColor: headerBackgroundColor ?? AppColors.surfaceDark,
                  foregroundColor: headerForegroundColor ?? Colors.white,
                  hasBackgroundImage: hasImage,
                ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimens.gap20, horizontal: AppDimens.gap16),
                child: _body(fg),
              ),
              if (hasActions)
                Padding(
                  padding: const EdgeInsets.only(left: AppDimens.gap16, right: AppDimens.gap16, bottom: AppDimens.gap16),
                  child: OverflowBar(spacing: AppDimens.gap8, alignment: MainAxisAlignment.end, children: actions!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(Color fg) {
    if (content != null) return content!;
    if (message != null) {
      return Text(message!, style: TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.4));
    }
    return const SizedBox.shrink();
  }
}
