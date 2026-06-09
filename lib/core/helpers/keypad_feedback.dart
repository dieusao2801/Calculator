import 'package:calculator/core/helpers/audio_helper.dart';
import 'package:calculator/core/helpers/vibration_helper.dart';

/// Facade phản hồi vật lý khi user tap bàn phím calculator.
///
/// Mapping từ Android gốc:
/// - `SoundUtils.play(context)` → [AudioHelper.playAsset] với asset `typing`.
/// - `VibrateUtils.vibrate(50)` → [VibrationHelper.tap] (50ms).
///
/// Hai flag bật/tắt độc lập đọc qua [AudioHelper.enabled] và
/// [VibrationHelper.enabled] — sync từ `SettingsController`.
///
/// Fire-and-forget: không await để UI mượt khi tap nhanh liên tục.
class KeypadFeedback {
  KeypadFeedback._();

  /// Path tương đối tới file âm thanh tap (không có prefix `assets/`).
  /// Asset thực tế đặt tại `assets/audio/typing.mp3`.
  static const String _typingAsset = 'audio/typing.mp3';

  /// Phát phản hồi tap bàn phím — đồng thời phát sound + vibrate.
  /// Hai helper tự check flag `enabled` của riêng mình nên không cần check
  /// trùng ở đây.
  static void tap() {
    AudioHelper.playAsset(_typingAsset);
    VibrationHelper.tap();
  }
}
