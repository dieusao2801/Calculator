import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:flutter/material.dart';

/// Mode hiển thị bottom sheet.
enum AppBottomSheetMode {
  /// Cao tự nhiên theo content (`mainAxisSize: min`).
  wrap,

  /// Có thể kéo lên/xuống trong khoảng [min, max].
  draggable,

  /// Chiếm gần full màn hình.
  fullscreen,
}

/// Base bottom sheet thống nhất: rounded top corners, drag handle, header,
/// scrollable body. KHÔNG bind feature cụ thể.
///
/// Gọi qua [AppBottomSheet.show]. Caller truyền widget body qua [child].
class AppBottomSheet {
  AppBottomSheet._();

  /// Hiển thị bottom sheet.
  ///
  /// [mode]: chế độ kích thước (wrap / draggable / fullscreen).
  /// [initialSize], [minSize], [maxSize]: dùng cho mode draggable, giá trị 0-1.
  /// [showDragHandle]: hiện thanh kéo phía trên (mặc định true).
  /// [isDismissible]: tap outside để đóng (mặc định true).
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    AppBottomSheetMode mode = AppBottomSheetMode.wrap,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double initialSize = 0.5,
    double minSize = 0.25,
    double maxSize = 0.95,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      builder: (_) => _AppBottomSheetBody(
        title: title,
        mode: mode,
        showDragHandle: showDragHandle,
        initialSize: initialSize,
        minSize: minSize,
        maxSize: maxSize,
        child: child,
      ),
    );
  }
}

class _AppBottomSheetBody extends StatelessWidget {
  const _AppBottomSheetBody({
    required this.child,
    required this.mode,
    required this.showDragHandle,
    required this.initialSize,
    required this.minSize,
    required this.maxSize,
    this.title,
  });

  final Widget child;
  final String? title;
  final AppBottomSheetMode mode;
  final bool showDragHandle;
  final double initialSize;
  final double minSize;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case AppBottomSheetMode.wrap:
        return _wrap(context);
      case AppBottomSheetMode.fullscreen:
        return _fullscreen(context);
      case AppBottomSheetMode.draggable:
        return _draggable(context);
    }
  }

  /// Mode wrap: chiều cao tự nhiên theo content, không scroll trừ khi body tự scroll.
  Widget _wrap(BuildContext context) {
    return _surface(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) const _DragHandle(),
          if (title != null) _Header(title: title!),
          Flexible(child: child),
        ],
      ),
    );
  }

  /// Mode fullscreen: chiếm ~95% chiều cao màn hình.
  Widget _fullscreen(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.95;
    return _surface(
      context,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            if (showDragHandle) const _DragHandle(),
            if (title != null) _Header(title: title!),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  /// Mode draggable: dùng DraggableScrollableSheet, body cần dùng controller scroll.
  Widget _draggable(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      expand: false,
      builder: (ctx, scrollController) {
        return _surface(
          ctx,
          child: Column(
            children: [
              if (showDragHandle) const _DragHandle(),
              if (title != null) _Header(title: title!),
              Expanded(
                child: PrimaryScrollController(controller: scrollController, child: child),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Container nền trắng với rounded top corners — dùng chung cho cả 3 mode.
  Widget _surface(BuildContext context, {required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.gap16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimens.gap8, bottom: AppDimens.gap4),
      width: AppDimens.gap36,
      height: AppDimens.gap4,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimens.gap2),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap16, vertical: AppDimens.gap12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            color: AppColors.textSecondary,
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
