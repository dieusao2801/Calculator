import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  /// Chia sẻ văn bản qua System Share Sheet (Intent trên Android).
  static Future<void> shareText(String text, {String? subject}) async {
    if (text.isEmpty) return;
    await Share.share(text, subject: subject);
  }
}
