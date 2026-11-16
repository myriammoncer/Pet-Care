import 'package:dio/dio.dart';

/// Appels réseau pour la réinitialisation du mot de passe (routes publiques /auth/*).
/// Ces routes ne nécessitent PAS de token JWT (l'intercepteur ne l'ajoute pas sur /auth/).
class PasswordResetApi {
  PasswordResetApi(this._dio);
  final Dio _dio;

  /// Étape 1 : demande un lien / jeton de réinitialisation.
  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  /// Étape 2 : envoie le jeton reçu + le nouveau mot de passe.
  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _dio.post('/auth/reset-password', data: {
      'token': token,
      'newPassword': newPassword,
    });
  }
}