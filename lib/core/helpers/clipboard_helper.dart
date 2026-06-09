import 'package:calculator/core/helpers/app_toast.dart';
import 'package:calculator/core/helpers/platform_info.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ClipboardHelper {
  ClipboardHelper._();

  /// Copy [text] vào clipboard. Trả `true` nếu OK.
  /// Truyền [context] để show toast xác nhận; trên Android 13+ skip vì hệ thống
  /// đã tự show clipboard preview overlay (tránh dư UI).
  static Future<bool> copy(String text, {BuildContext? context}) async {
    if (text.isEmpty) return false;
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context != null && context.mounted && !PlatformInfo.shouldSkipClipboardToast) {
        AppToast.show(context, t.common.copied);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
