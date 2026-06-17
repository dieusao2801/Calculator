import 'dart:convert';
import 'dart:io' show GZipCodec;
import 'dart:math' show Random;

/// Build query `param` cho `/calc.php` — port nguyên `EncodeHelper.encodeBase64`
/// bên Android. Pipeline:
///   1. plain = "date=YYYY-MM-DD" (UTC)
///   2. gzip → base64
///   3. chèn 5 ký tự random ở index 10 của base64
///   4. bọc 5 random ở đầu + 5 random ở cuối
///   5. URL encode (Dio dùng `encoded: true` nên builder tự encode)
String buildCurrencyParam([DateTime? now]) {
  final utc = (now ?? DateTime.now()).toUtc();
  final y = utc.year.toString().padLeft(4, '0');
  final m = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  final plain = 'date=$y-$m-$d';

  final compressed = GZipCodec().encode(utf8.encode(plain));
  final b64 = base64.encode(compressed);

  final salted =
      _randomSalt(5) +
      b64.substring(0, 10) +
      _randomSalt(5) +
      b64.substring(10) +
      _randomSalt(5);

  return Uri.encodeComponent(salted.replaceAll('\n', ''));
}

const String _kSaltChars =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
final Random _rnd = Random.secure();

String _randomSalt(int len) {
  final sb = StringBuffer();
  for (var i = 0; i < len; i++) {
    sb.write(_kSaltChars[_rnd.nextInt(_kSaltChars.length)]);
  }
  return sb.toString();
}
