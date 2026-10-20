import 'package:dio/dio.dart';

import 'token_storage.dart';

/// Intercepteur dio :
/// 1. ajoute `Authorization: Bearer <accessToken>` à chaque requête ;
/// 2. sur un 401, tente un refresh du token puis rejoue la requête une fois.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.tokenStorage});

  final Dio dio;
  final TokenStorage tokenStorage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Les routes d'authentification ne portent pas de token.
    if (!options.path.contains('/auth/')) {
      final token = await tokenStorage.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (isUnauthorized && !alreadyRetried) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        try {
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {
          // laisse l'erreur originale se propager
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await tokenStorage.refreshToken;
    if (refresh == null) return false;
    try {
      final response = await dio.post('/auth/refresh', data: {'refreshToken': refresh});
      final data = response.data['data'] as Map<String, dynamic>;
      await tokenStorage.saveTokens(
        access: data['accessToken'] as String,
        refresh: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      await tokenStorage.clear();
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) {
    final token = options.headers['Authorization'];
    return dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {...options.headers, if (token != null) 'Authorization': token},
        extra: {...options.extra, 'retried': true},
      ),
    );
  }
}
