import 'dart:async';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppToast {
  static OverlayEntry? _currentEntry;

  AppToast._();

  static void show(BuildContext context, String message) {
    if (_currentEntry != null) {
      _currentEntry?.remove();
      _currentEntry = null;
    }

    // rootOverlay: true để toast sống độc lập với route stack (dialog/sheet pop không xoá toast).
    final overlay = Overlay.of(context, rootOverlay: true);
    _currentEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        onDismissed: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({required this.message, required this.onDismissed});
  final String message;
  final VoidCallback onDismissed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismissed());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacity,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF323232).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
