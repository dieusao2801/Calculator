part of '../app_theme_ext.dart';

/// Token cho panel hiển thị biểu thức — gom style, cặp màu bg outer/inner
/// và 3 màu text (primary/secondary/error).
@immutable
class DisplayPanelGroup {
  const DisplayPanelGroup({
    required this.bgOuter,
    required this.bgInner,
    required this.textPrimary,
    required this.textSecondary,
    required this.textError,
  });

  final Color bgOuter;
  final Color bgInner;
  final Color textPrimary;
  final Color textSecondary;
  final Color textError;

  DisplayPanelGroup copyWith({
    Color? bgOuter,
    Color? bgInner,
    Color? textPrimary,
    Color? textSecondary,
    Color? textError,
  }) => DisplayPanelGroup(
    bgOuter: bgOuter ?? this.bgOuter,
    bgInner: bgInner ?? this.bgInner,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textError: textError ?? this.textError,
  );

  static DisplayPanelGroup lerp(DisplayPanelGroup a, DisplayPanelGroup b, double t) =>
      DisplayPanelGroup(
        bgOuter: _lerpColor(a.bgOuter, b.bgOuter, t),
        bgInner: _lerpColor(a.bgInner, b.bgInner, t),
        textPrimary: _lerpColor(a.textPrimary, b.textPrimary, t),
        textSecondary: _lerpColor(a.textSecondary, b.textSecondary, t),
        textError: _lerpColor(a.textError, b.textError, t),
      );
}
