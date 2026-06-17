import 'dart:convert';
import 'dart:io' show GZipCodec;

/// Decode response server — port nguyên `EncodeHelper.decodeBase64` bên Android.
/// Pipeline (đảo ngược encode):
///   1. URL decode (no-op nếu server không URL-encode)
///   2. strip 5 ký tự đầu + 5 ký tự cuối (salt random)
///   3. strip 5 ký tự ở index 10-14 (salt random ở giữa)
///   4. base64 decode → gzip decompress → UTF-8
///
/// Throw `FormatException` nếu input < 25 ký tự (không đủ salt) hoặc decode lỗi.
String decodeCurrencyResponse(String body) {
  final trimmed = body.trim();
  if (trimmed.length < 25) {
    throw FormatException('Response quá ngắn (${trimmed.length} chars)');
  }
  final urlDecoded = Uri.decodeComponent(trimmed);
  final stripped = urlDecoded.substring(5, urlDecoded.length - 5);
  final cleanB64 = stripped.substring(0, 10) + stripped.substring(15);
  final compressed = base64.decode(cleanB64);
  final bytes = GZipCodec().decode(compressed);
  return utf8.decode(bytes);
}
