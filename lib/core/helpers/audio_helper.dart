import 'package:audioplayers/audioplayers.dart';
import 'package:calculator/core/log/app_log.dart';

/// Helper phát âm thanh, wrap plugin `audioplayers`.
///
/// Dùng cho UI sounds (click, success, error). Mỗi lần gọi sẽ stop player
/// hiện tại rồi play file mới — tránh overlap khó chịu khi user bấm nhanh.
///
/// Asset audio phải nằm trong `assets/audio/` và được khai báo trong
/// `pubspec.yaml`. Truyền path tương đối từ thư mục assets, KHÔNG có prefix
/// `assets/` (vd: `'audio/click.mp3'`).
class AudioHelper {
  AudioHelper._();

  static final AudioPlayer _player = AudioPlayer();
  static bool enabled = true;

  /// [assetPath]: path tương đối trong thư mục assets, vd `'audio/click.mp3'`.
  static Future<void> playAsset(String assetPath) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      AppLog.e('AudioHelper.playAsset($assetPath): $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      AppLog.e('AudioHelper.stop: $e');
    }
  }

  static Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (e) {
      AppLog.e('AudioHelper.dispose: $e');
    }
  }
}
