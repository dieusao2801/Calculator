import 'package:calculator/features/converter/domain/converter_item.dart';
import 'package:calculator/features/converter/presentation/styles/converter_colors.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Khối icon vuông cho Converter item — 7 gradient themes, 2 size variant.
/// Chỉ hiển thị khối icon chính. Các nút Add/Remove được quản lý bởi widget cha.
class ConverterIconTile extends ConsumerWidget {
  const ConverterIconTile({
    super.key,
    required this.icon,
    required this.theme,
    required this.contentId,
    this.big = false,
    this.size,
  });

  final SvgGenImage icon;
  final ConverterColorTheme theme;
  final String contentId;
  final bool big;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveSize = size ?? (big ? 70.0 : 56.0);
    final radius = big ? 16.0 : 10.0;
    final iconSize = big ? 28.0 : 24.0;
    final gradient = theme.gradient;

    // RepaintBoundary giúp tối ưu khi scroll
    return RepaintBoundary(
      child: Container(
        width: effectiveSize,
        height: effectiveSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradient.top, gradient.bottom],
          ),
          border: Border.all(color: Colors.black.withValues(alpha: 0.8), width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: icon.svg(
            width: iconSize,
            height: iconSize,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
