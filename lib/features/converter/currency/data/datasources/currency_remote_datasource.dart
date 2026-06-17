import 'dart:convert';

import 'package:calculator/features/converter/currency/data/api/currency_api.dart';
import 'package:calculator/features/converter/currency/data/helpers/currency_param_builder.dart';
import 'package:calculator/features/converter/currency/data/helpers/currency_response_codec.dart';
import 'package:calculator/features/converter/currency/data/models/currency_response_dto.dart';

class CurrencyRemoteDataSource {
  CurrencyRemoteDataSource(this._api);

  final CurrencyApi _api;

  /// Gọi `/calc.php`, decode Base64, parse JSON → DTO.
  /// Throw `FormatException` / `DioException` lên caller xử lý.
  Future<CurrencyResponseDto> getExchangeRates() async {
    final base64Body = await _api.getExchangeRates(param: buildCurrencyParam());
    final jsonStr = decodeCurrencyResponse(base64Body);
    final Map<String, dynamic> map = json.decode(jsonStr) as Map<String, dynamic>;
    return CurrencyResponseDto.fromJson(map);
  }
}
