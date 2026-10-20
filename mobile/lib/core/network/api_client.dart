import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Fabrique le client HTTP `dio` configuré pour l'API Pet-Care :
/// base URL, en-têtes JSON, timeouts et intercepteur JWT (+ refresh sur 401).
class ApiClient {
  ApiClient({required AppConfig config, required TokenStorage tokenStorage})
      : dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            contentType: 'application/json',
            headers: {'Accept': 'application/json'},
          ),
        ) {
    dio.interceptors.add(AuthInterceptor(dio: dio, tokenStorage: tokenStorage));
  }

  final Dio dio;
}
