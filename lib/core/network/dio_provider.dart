import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_endpoints.dart';

part 'dio_provider.g.dart';

/// Singleton Dio dùng chung — keepAlive vì connection pool nên sống cùng app.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.currencyBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // Logger HTTP giống OkHttp — chỉ bật ở debug để tránh leak body/headers ở release.
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: false,
        maxWidth: 120,
      ),
    );
  }

  return dio;
}
