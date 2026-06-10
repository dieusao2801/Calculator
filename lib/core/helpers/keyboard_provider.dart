import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keyboard_provider.g.dart';

@riverpod
class KeyboardVisibility extends _$KeyboardVisibility with WidgetsBindingObserver {
  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));

    return _checkVisibility();
  }

  bool _checkVisibility() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return false;
    return views.first.viewInsets.bottom > 0;
  }

  @override
  void didChangeMetrics() {
    state = _checkVisibility();
  }
}
