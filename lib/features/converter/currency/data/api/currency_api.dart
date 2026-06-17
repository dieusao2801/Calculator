import 'package:calculator/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'currency_api.g.dart';

/// Retrofit interface cho Currency endpoint.
/// `@DioResponseType(plain)` để Dio không tự parse JSON — server trả Base64
/// string, repo tự decode trước khi parse.
@RestApi()
abstract class CurrencyApi {
  factory CurrencyApi(Dio dio, {String baseUrl}) = _CurrencyApi;

  @GET(ApiEndpoints.currencyRates)
  @DioResponseType(ResponseType.plain)
  Future<String> getExchangeRates({@Query('param', encoded: true) required String param});
}
