import 'package:flutter/material.dart';

const double _kMaxFontSize = 22;
const double _kMinFontSize = 12;
const FontWeight _kFontWeight = FontWeight.w400;
const Color _kTextColor = Color(0xFF111111);

class CurrencyInput extends StatelessWidget {
  const CurrencyInput({super.key, required this.value, required this.focused, this.onTap});

  final String value;
  final bool focused;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final display = _format(value);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: focused ? const Color(0xFF2196F3) : const Color(0xFF4A4A4A), width: 1.2),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Chừa chỗ cho cursor khi focused (2px width + 6px margin trái)
            final cursorReserve = focused ? 8.0 : 0.0;
            final fontSize = _fitFontSize(display, constraints.maxWidth - cursorReserve);
            return Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: fontSize, color: _kTextColor, fontWeight: _kFontWeight),
                  ),
                ),
                if (focused) const _BlinkingCursor(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Thêm `,` mỗi 3 chữ số phần nguyên; giữ `.` cho thập phân.
String _format(String raw) {
  if (raw.isEmpty) return '';
  final negative = raw.startsWith('-');
  final s = negative ? raw.substring(1) : raw;
  final dot = s.indexOf('.');
  final intPart = dot < 0 ? s : s.substring(0, dot);
  final decPart = dot < 0 ? '' : s.substring(dot);

  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  final result = '$buf$decPart';
  return negative ? '-$result' : result;
}

double _fitFontSize(String text, double maxWidth) {
  if (maxWidth <= 0 || text.isEmpty) return _kMaxFontSize;
  var size = _kMaxFontSize;
  while (size > _kMinFontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size, fontWeight: _kFontWeight),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    if (tp.width <= maxWidth) break;
    size -= 1;
  }
  return size;
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => Opacity(
        opacity: _controller.value < 0.5 ? 1 : 0,
        child: Container(width: 1.5, height: 24, color: Colors.black),
      ),
    );
  }
}
