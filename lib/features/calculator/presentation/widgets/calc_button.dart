import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/theme/app_theme_ext.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// Các variant nút theo design system của máy tính.
enum CalcButtonVariant {
  /// Số 0–9, dấu phẩy, 00 — nền sáng, chữ tối.
  digit,

  /// Toán tử + − × ÷ — nền nổi bật (thường là cam).
  operator,

  /// Phép tính phụ (sin, cos, ^, √, %, ±, ( )) — nền xám trung tính.
  function,

  /// Xóa lùi (⌫) — thường cùng nhóm màu với function.
  delete,

  /// Xóa tất cả (C/AC) — cần nổi bật để cảnh báo (thường là đỏ).
  clear,

  /// Equals (=) — nút quan trọng nhất, nền cam đậm.
  equals,
}

class CalcButton extends StatelessWidget {
  const CalcButton({super.key, required this.variant, this.label, this.icon, this.svgIcon, this.onPressed, this.iconSize})
    : assert(label != null || icon != null || svgIcon != null, 'Cần label, icon hoặc svgIcon');

  final CalcButtonVariant variant;
  final String? label;
  final IconData? icon;
  final SvgGenImage? svgIcon;
  final VoidCallback? onPressed;
  final double? iconSize;

  bool get _disabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme.button.forVariant(variant);
    final bg = _disabled ? theme.bg.withValues(alpha: 0.5) : theme.bg;
    final fg = _disabled ? theme.fg.withValues(alpha: 0.5) : theme.fg;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.gap4),
        // Ảnh nền sẽ chiếm toàn bộ diện tích, color/gradient chỉ dùng khi không có ảnh
        color: theme.bgImage == null ? bg : null,
        image: theme.bgImage != null ? DecorationImage(image: theme.bgImage!, fit: BoxFit.fill) : null,
        border: theme.bgImage == null ? Border.all(color: const Color(0xFF4D4D4D), width: 1.0) : null,
        boxShadow: theme.bgImage == null
            ? [
                BoxShadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(0, 1.5), blurRadius: 1.5),
                BoxShadow(color: Colors.white.withValues(alpha: 0.2), offset: const Offset(0, 0.5), blurRadius: 0.5),
              ]
            : null,
        gradient: theme.bgImage == null
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(bg, Colors.white, 0.25)!, bg, Color.lerp(bg, Colors.black, 0.15)!],
                stops: const [0.0, 0.4, 1.0],
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimens.gap10),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.gap4),
            child: Center(child: _buildContent(fg)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color fg) {
    final size = iconSize ?? AppDimens.gap48;

    if (svgIcon != null) {
      return svgIcon!.svg(width: size, height: size, colorFilter: ColorFilter.mode(fg, BlendMode.srcIn));
    }

    if (icon != null) {
      return Icon(icon, size: size, color: fg);
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label ?? '',
        style: AppTextStyles.calcButtonLabel.copyWith(color: fg),
        textAlign: TextAlign.center,
      ),
    );
  }
}
