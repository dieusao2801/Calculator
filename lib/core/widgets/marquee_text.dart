import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

/// Text cuộn ngang khi nội dung dài hơn vùng hiển thị — fit thì render tĩnh.
class MarqueeText extends StatelessWidget {
  const MarqueeText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.velocity = 30,
    this.blankSpace = 40,
    this.pauseAfterRound = const Duration(seconds: 1),
    this.startAfter = const Duration(milliseconds: 800),
    this.fadingEdgeStartFraction = 0.1,
    this.fadingEdgeEndFraction = 0.1,
    this.height,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final double velocity;
  final double blankSpace;
  final Duration pauseAfterRound;
  final Duration startAfter;
  final double fadingEdgeStartFraction;
  final double fadingEdgeEndFraction;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: effectiveStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();

        final fits = tp.width <= constraints.maxWidth;
        if (fits) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: effectiveStyle,
          );
        }

        return SizedBox(
          height: height ?? tp.height,
          child: Marquee(
            text: text,
            style: effectiveStyle,
            velocity: velocity,
            blankSpace: blankSpace,
            pauseAfterRound: pauseAfterRound,
            startAfter: startAfter,
            startPadding: 0,
            fadingEdgeStartFraction: fadingEdgeStartFraction,
            fadingEdgeEndFraction: fadingEdgeEndFraction,
            showFadingOnlyWhenScrolling: true,
          ),
        );
      },
    );
  }
}
