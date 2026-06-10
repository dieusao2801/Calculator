import 'package:calculator/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// Color theme cho icon background của mỗi item — 7 biến thể khớp ảnh mockup.
enum ConverterColorTheme {
  /// Slate xám xanh medium-dark — section Convert + favorite #2.
  bluish,

  /// Teal đậm — section Money + favorite #6, #8.
  lightBlue,

  /// Mận đỏ — section Health + favorite #5.
  coral,

  /// Charcoal xám rất tối — section Consume + favorite #4.
  beige,

  /// Lavender blue-grey nhạt — favorite #1.
  lavender,

  /// Tím wine đậm — favorite #3.
  purple,

  /// Teal medium nhạt — favorite #7.
  tealLight,
}

/// Một công cụ quy đổi trong Converter tab (Unit Converter, Date Difference, ...).
@immutable
class ConverterItem {
  const ConverterItem({
    required this.id,
    required this.contentId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.theme,
  });

  final String id;
  final String contentId;
  final String title;
  final String subtitle;
  final SvgGenImage icon;
  final ConverterColorTheme theme;
}

/// Section gom nhóm các [ConverterItem] cùng chủ đề (Convert, Consume, Health, Money).
@immutable
class ConverterSection {
  const ConverterSection({required this.id, required this.title, required this.items});

  final String id;
  final String title;
  final List<ConverterItem> items;
}
