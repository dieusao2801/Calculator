import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';

/// Cache thông tin platform để branch behavior runtime.
/// Phải gọi [init] 1 lần ở `main.dart` trước `runApp`.
class PlatformInfo {
  PlatformInfo._();

  static int? _androidSdkInt;

  static int? get androidSdkInt => _androidSdkInt;

  static Future<void> init() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      _androidSdkInt = info.version.sdkInt;
    }
  }

  /// Android 13 (API 33) trở lên hệ thống tự show clipboard preview overlay.
  /// Tuy nhiên, nhiều hãng (Oppo, Samsung...) cũng tự show toast/overlay riêng.
  /// Để tránh "view thừa" (như feedback người dùng), ta skip toast trên mọi Android.
  static bool get shouldSkipClipboardToast {
    return Platform.isAndroid;
  }
}
