import 'package:dio/dio.dart';

import '../domain/auth_user.dart';

/// Résultat d'authentification côté data (tokens + utilisateur).
class AuthResult {
  const AuthResult({required this.accessToken, required this.refreshToken, required this.user});

  final String accessToken;
  final String refreshToken;
  final AuthUser user;
}

/// Appels réseau liés à l'authentification.
class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  Future<AuthResult> login(String email, String password) {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  Future<AuthResult> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) {
    return _post('/auth/signup', {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    });
  }

  Future<AuthResult> _post(String path, Map<String, dynamic> body) async {
    final response = await _dio.post(path, data: body);
    final data = response.data['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return AuthResult(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: AuthUser(
        id: user['id'] as String,
        email: user['email'] as String,
        firstName: user['firstName'] as String? ?? '',
        lastName: user['lastName'] as String? ?? '',
        roles: (user['roles'] as List<dynamic>).map((e) => e.toString()).toList(),
      ),
    );
  }
}
