import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Cầu nối sang native `android.util.Log` để Logcat tô màu theo đúng level.
/// Platform khác Android (iOS / Web / desktop) → fallback `debugPrint`.
class NativeLogChannel {
  static const MethodChannel _channel = MethodChannel('app/native_log');
  static const String _tag = 'AppLog';

  /// Giới hạn an toàn dưới 4096 ký tự / call của `__android_log_write`.
  static const int _chunkSize = 4000;

  /// [level]: `'v' | 'd' | 'i' | 'w' | 'e' | 'f'`
  static void log(String level, String message) {
    if (!kDebugMode) return;
    if (!_isAndroid) {
      debugPrint('[$level] $message');
      return;
    }
    for (final chunk in _chunk(message)) {
      unawaited(_invoke(level, chunk));
    }
  }

  static Future<void> _invoke(String level, String chunk) async {
    try {
      await _channel.invokeMethod<void>('log', {
        'level': level,
        'tag': _tag,
        'message': chunk,
      });
    } catch (_) {
      // Channel chưa register / lỗi bridge → fallback console.
      debugPrint('[$level] $chunk');
    }
  }

  static bool get _isAndroid {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  static Iterable<String> _chunk(String input) sync* {
    if (input.length <= _chunkSize) {
      yield input;
      return;
    }
    var start = 0;
    while (start < input.length) {
      final end = start + _chunkSize > input.length ? input.length : start + _chunkSize;
      yield input.substring(start, end);
      start = end;
    }
  }
}
