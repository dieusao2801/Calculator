import 'package:calculator/core/log/app_log.dart';
import 'package:vibration/vibration.dart';

/// Helper rung thiết bị, wrap plugin `vibration`.
///
/// Cung cấp 3 preset (light/medium/heavy) + pattern tuỳ biến.
/// Tự kiểm tra hardware support, no-op nếu không có vibrator.
///
/// Bật/tắt toàn cục qua [enabled] — caller (vd Settings) toggle khi user
/// thay đổi preference.
class VibrationHelper {
  VibrationHelper._();

  /// Toggle toàn cục. Khi false, mọi gọi vibrate đều no-op.
  static bool enabled = true;

  /// Cache result của `Vibration.hasVibrator()` để tránh check lặp.
  static bool? _hasVibratorCache;

  /// Có hardware vibrator không.
  static Future<bool> get hasVibrator async {
    return _hasVibratorCache ??= (await Vibration.hasVibrator());
  }

  /// Rung nhẹ — tap nút thường.
  static Future<void> light() => _vibrate(duration: 10, amplitude: 64);

  /// Rung vừa — toán tử / action.
  static Future<void> medium() => _vibrate(duration: 30, amplitude: 128);

  /// Rung mạnh — `=` / error.
  static Future<void> heavy() => _vibrate(duration: 60, amplitude: 255);

  /// Pattern tuỳ biến: `[waitMs, vibrateMs, waitMs, vibrateMs, ...]`.
  static Future<void> pattern(List<int> pattern) async {
    if (!enabled) return;
    if (!await hasVibrator) return;
    try {
      await Vibration.vibrate(pattern: pattern);
    } catch (e) {
      AppLog.e('VibrationHelper.pattern: $e');
    }
  }

  /// Huỷ vibration đang chạy.
  static Future<void> cancel() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      AppLog.e('VibrationHelper.cancel: $e');
    }
  }

  static Future<void> _vibrate({required int duration, int amplitude = 128}) async {
    if (!enabled) return;
    if (!await hasVibrator) return;
    try {
      await Vibration.vibrate(duration: duration, amplitude: amplitude);
    } catch (e) {
      AppLog.e('VibrationHelper.vibrate: $e');
    }
  }
}