import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final String _apiUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.3:4000/api',
  );

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: _apiUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              const storage = FlutterSecureStorage();
              final token = await storage.read(key: 'accessToken');
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              return handler.next(options);
            },
          ),
        );

  static Dio get instance => _dio;
}
