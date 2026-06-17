import 'package:json_annotation/json_annotation.dart';

part 'currency_response_dto.g.dart';

/// Response của `/calc.php` sau khi đã base64-decode.
/// Schema giống currencylayer.com:
/// ```
/// { "success": true, "timestamp": 1719676800, "source": "USD",
///   "quotes": { "USDEUR": 0.93, "USDVND": 24500, ... } }
/// ```
@JsonSerializable(createToJson: false)
class CurrencyResponseDto {
  final bool success;
  final int timestamp;
  final String? source;
  final Map<String, double> quotes;

  const CurrencyResponseDto({required this.success, required this.timestamp, this.source, required this.quotes});

  factory CurrencyResponseDto.fromJson(Map<String, dynamic> json) => _$CurrencyResponseDtoFromJson(json);
}