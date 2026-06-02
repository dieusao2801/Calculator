part of '../app_theme_ext.dart';

/// Cấu hình giao diện nút: màu nền, màu chữ và ảnh nền tùy chọn.
typedef CalcButtonTheme = ({Color bg, Color fg, ImageProvider? bgImage});

CalcButtonTheme _lerpButtonTheme(CalcButtonTheme a, CalcButtonTheme b, double t) => (
  bg: _lerpColor(a.bg, b.bg, t),
  fg: _lerpColor(a.fg, b.fg, t),
  bgImage: _snap(a.bgImage, b.bgImage, t),
);

/// Token cho nút calculator — gom cấu hình giao diện cho các variant.
@immutable
class CalcButtonGroup {
  const CalcButtonGroup({
    required this.digit,
    required this.operator,
    required this.function,
    required this.delete,
    required this.clear,
    required this.equals,
  });

  final CalcButtonTheme digit;
  final CalcButtonTheme operator;
  final CalcButtonTheme function;
  final CalcButtonTheme delete;
  final CalcButtonTheme clear;
  final CalcButtonTheme equals;

  /*
    Chức năng: Trả cấu hình (bg, fg, bgImage) tương ứng với [variant] của nút.
    Gọi tại: `calc_button.dart` widget.
  */
  CalcButtonTheme forVariant(CalcButtonVariant variant) => switch (variant) {
    CalcButtonVariant.digit => digit,
    CalcButtonVariant.operator => operator,
    CalcButtonVariant.function => function,
    CalcButtonVariant.delete => delete,
    CalcButtonVariant.clear => clear,
    CalcButtonVariant.equals => equals,
  };

  CalcButtonGroup copyWith({
    CalcButtonTheme? digit,
    CalcButtonTheme? operator,
    CalcButtonTheme? function,
    CalcButtonTheme? delete,
    CalcButtonTheme? clear,
    CalcButtonTheme? equals,
  }) => CalcButtonGroup(
    digit: digit ?? this.digit,
    operator: operator ?? this.operator,
    function: function ?? this.function,
    delete: delete ?? this.delete,
    clear: clear ?? this.clear,
    equals: equals ?? this.equals,
  );

  static CalcButtonGroup lerp(CalcButtonGroup a, CalcButtonGroup b, double t) => CalcButtonGroup(
    digit: _lerpButtonTheme(a.digit, b.digit, t),
    operator: _lerpButtonTheme(a.operator, b.operator, t),
    function: _lerpButtonTheme(a.function, b.function, t),
    delete: _lerpButtonTheme(a.delete, b.delete, t),
    clear: _lerpButtonTheme(a.clear, b.clear, t),
    equals: _lerpButtonTheme(a.equals, b.equals, t),
  );
}
