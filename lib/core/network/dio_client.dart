import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:reminder_app/core/network/api_interceptor.dart';
import 'package:reminder_app/core/network/api_endpoints.dart';

class DioClient {
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(milliseconds: connectTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Configure HttpClient to ignore SSL certificate verification
    // WARNING: Only use this in development. Remove in production!
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    dio.interceptors.addAll([
      ApiInterceptor(),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);

    return dio;
  }
}
