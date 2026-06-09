import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/theme/app_theme_ext.dart';
import 'package:flutter/material.dart';

/// Mode hiển thị bottom sheet.
enum AppBottomSheetMode {
  /// Cao tự nhiên theo content (`mainAxisSize: min`).
  wrap,

  /// Có thể kéo lên/xuống trong khoảng [minSize, maxSize].
  draggable,

  /// Chiếm ~95% chiều cao màn hình.
  fullscreen,
}

/// Base bottom sheet: rounded top, drag handle, header, scrollable body.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool showCloseButton = true,
    AppBottomSheetMode mode = AppBottomSheetMode.wrap,
    bool showDragHandle = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool dismissOnDragDown = false,
    double initialSize = 1.0,
    double minSize = 0.3,
    double maxSize = 1.0,
    double? maxHeight,
    Color? headerBackgroundColor,
    Color? headerForegroundColor,
    Color? backgroundColor,
    bool useBackgroundImage = true,
    ImageProvider? backgroundImage,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight) : null,
      builder: (_) => _SheetView(
        mode: mode,
        title: title,
        actions: actions,
        showCloseButton: showCloseButton,
        showDragHandle: showDragHandle,
        dismissOnDragDown: dismissOnDragDown,
        initialSize: initialSize,
        minSize: minSize,
        maxSize: maxSize,
        headerBackgroundColor: headerBackgroundColor,
        headerForegroundColor: headerForegroundColor,
        backgroundColor: backgroundColor,
        useBackgroundImage: useBackgroundImage,
        backgroundImage: backgroundImage,
        child: child,
      ),
    );
  }
}

/// Dựng [BoxDecoration] cho surface của sheet/dialog.
BoxDecoration sheetSurfaceDecoration({
  required BuildContext context,
  required BorderRadius borderRadius,
  required bool useBackgroundImage,
  ImageProvider? backgroundImage,
  Color? backgroundColor,
}) {
  final image = useBackgroundImage ? (backgroundImage ?? context.appTheme.background.homeImage) : null;
  return BoxDecoration(
    color: backgroundColor ?? (image == null ? AppColors.surfaceWhite : null),
    borderRadius: borderRadius,
    image: image != null ? DecorationImage(image: image, fit: BoxFit.cover, filterQuality: FilterQuality.low) : null,
  );
}

class _SheetView extends StatefulWidget {
  const _SheetView({
    required this.child,
    required this.mode,
    required this.showDragHandle,
    required this.showCloseButton,
    required this.dismissOnDragDown,
    required this.initialSize,
    required this.minSize,
    required this.maxSize,
    required this.useBackgroundImage,
    this.title,
    this.actions,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.backgroundColor,
    this.backgroundImage,
  });

  final Widget child;
  final AppBottomSheetMode mode;
  final String? title;
  final List<Widget>? actions;
  final bool showCloseButton;
  final bool showDragHandle;
  final bool dismissOnDragDown;
  final double initialSize;
  final double minSize;
  final double maxSize;
  final Color? headerBackgroundColor;
  final Color? headerForegroundColor;
  final Color? backgroundColor;
  final bool useBackgroundImage;
  final ImageProvider? backgroundImage;

  @override
  State<_SheetView> createState() => _SheetViewState();
}

class _SheetViewState extends State<_SheetView> {
  DraggableScrollableController? _dragController;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == AppBottomSheetMode.draggable) {
      _dragController = DraggableScrollableController();
      if (widget.dismissOnDragDown) {
        _dragController!.addListener(_onDragSizeChanged);
      }
    }
  }

  @override
  void dispose() {
    _dragController?.dispose();
    super.dispose();
  }

  void _onDragSizeChanged() {
    if (_dismissed || !mounted) return;
    final c = _dragController;
    if (c == null || !c.isAttached) return;
    if (c.size < 0.1) {
      _dismissed = true;
      context.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.useBackgroundImage;

    switch (widget.mode) {
      case AppBottomSheetMode.wrap:
        return _surface(child: _content(hasImage, expand: false));

      case AppBottomSheetMode.fullscreen:
        final height = MediaQuery.of(context).size.height * 0.95;
        return _surface(
          child: SizedBox(height: height, child: _content(hasImage, expand: true)),
        );

      case AppBottomSheetMode.draggable:
        final minChildSize = widget.dismissOnDragDown ? 0.0 : widget.minSize;
        return DraggableScrollableSheet(
          controller: _dragController,
          initialChildSize: widget.initialSize,
          minChildSize: minChildSize,
          maxChildSize: widget.maxSize,
          snap: true,
          expand: false,
          builder: (_, scrollController) =>
              _surface(child: _content(hasImage, expand: true, scrollController: scrollController)),
        );
    }
  }

  Widget _surface({required Widget child}) {
    return Container(
      decoration: sheetSurfaceDecoration(
        context: context,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.gap16)),
        useBackgroundImage: widget.useBackgroundImage,
        backgroundImage: widget.backgroundImage,
        backgroundColor: widget.backgroundColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _content(bool hasImage, {required bool expand, ScrollController? scrollController}) {
    final body = scrollController != null
        ? PrimaryScrollController(controller: scrollController, child: widget.child)
        : widget.child;
    return Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.showDragHandle) const _DragHandle(),
        if (widget.title != null)
          Header(
            title: widget.title!,
            actions: widget.actions,
            showCloseButton: widget.showCloseButton,
            backgroundColor: widget.headerBackgroundColor,
            foregroundColor: widget.headerForegroundColor,
            hasBackgroundImage: hasImage,
          ),
        expand ? Expanded(child: body) : Flexible(child: body),
      ],
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

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.title,
    required this.showCloseButton,
    required this.hasBackgroundImage,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String title;
  final List<Widget>? actions;
  final bool showCloseButton;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool hasBackgroundImage;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? (hasBackgroundImage ? Colors.white : AppColors.textPrimary);
    return Container(
      height: kToolbarHeight,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap16),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.headlineSmall.copyWith(color: fg)),
          ),
          if (actions != null) ...actions!,
          if (showCloseButton)
            IconButton(
              icon: Icon(Icons.close, size: 24, color: fg),
              onPressed: () => context.maybePop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
