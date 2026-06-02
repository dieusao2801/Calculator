import 'package:calculator/core/log/app_log.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Helper giữ màn hình sáng, wrap plugin `wakelock_plus`.
///
/// Plugin tự handle lifecycle: wakelock được giữ tới khi gọi [disable] hoặc
/// app bị huỷ. Battery saver của OS có thể override.
class WakelockHelper {
  WakelockHelper._();

  /// Trạng thái hiện tại (true = đang giữ màn hình sáng).
  static Future<bool> get isEnabled async {
    try {
      return await WakelockPlus.enabled;
    } catch (e) {
      AppLog.e('WakelockHelper.isEnabled: $e');
      return false;
    }
  }

  /// Bật giữ màn hình sáng.
  static Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      AppLog.e('WakelockHelper.enable: $e');
    }
  }

  /// Tắt giữ màn hình sáng (cho OS quản lý timeout bình thường).
  static Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      AppLog.e('WakelockHelper.disable: $e');
    }
  }

  /// Đảo trạng thái.
  static Future<void> toggle() async {
    final cur = await isEnabled;
    if (cur) {
      await disable();
    } else {
      await enable();
    }
  }
}