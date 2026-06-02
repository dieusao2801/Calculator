import 'package:flutter/foundation.dart';

import 'native_log_channel.dart';

class AppLog {
  static void info(dynamic message) {
    if (kDebugMode) {
      NativeLogChannel.log('i', "💡 $message --- ${_getCallerInfo()}");
    }
  }

  static void debug(dynamic message) {
    if (kDebugMode) {
      NativeLogChannel.log('d', "🔍 $message --- ${_getCallerInfo()}");
    }
  }

  static void warning(dynamic message) {
    if (kDebugMode) {
      NativeLogChannel.log('w', "⚠️ $message --- ${_getCallerInfo()}");
    }
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final String msg =
          "⛔ $message${error != null ? ' | Error: $error' : ''} --- ${_getCallerInfo()}";
      final String full = stackTrace != null ? "$msg\n$stackTrace" : msg;
      NativeLogChannel.log('e', full);
    }
  }

  static void exception(dynamic error, [StackTrace? stackTrace, String? message]) {
    AppLog.error(message ?? 'Exception occurred', error, stackTrace);
  }

  static void fatal(dynamic error, [StackTrace? stackTrace, String? message]) {
    if (kDebugMode) {
      final String msg = "💀 ${message ?? 'Fatal error'} | $error --- ${_getCallerInfo()}";
      final String full = stackTrace != null ? "$msg\n$stackTrace" : msg;
      NativeLogChannel.log('f', full);
    }
  }

  static String _getCallerInfo() {
    try {
      final lines = StackTrace.current.toString().split('\n');
      for (final line in lines) {
        if (line.contains('app_log.dart')) continue;
        final match = RegExp(r'#\d+\s+(.+)\s+\((.+)\)').firstMatch(line);
        if (match != null) {
          final methodName = match.group(1);
          final fileInfo = match.group(2);
          return "$methodName($fileInfo)";
        }
      }
    } catch (_) {}
    return "";
  }

  // Alias ngắn gọn giống Android
  static void d(dynamic m) => debug(m);
  static void i(dynamic m) => info(m);
  static void e(dynamic m, [dynamic err, StackTrace? st]) => error(m, err, st);
}
