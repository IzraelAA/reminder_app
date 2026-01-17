import 'package:dio/dio.dart';
import 'package:reminder_app/core/local_storage/hive_storage.dart';
import 'package:reminder_app/core/di/injection.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final storage = getIt<HiveStorage>();
    final token = storage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle errors globally
    if (err.response?.statusCode == 401) {
      // Handle unauthorized - clear token, navigate to login, etc.
      final storage = getIt<HiveStorage>();
      storage.clearToken();
    }
    super.onError(err, handler);
  }
}
