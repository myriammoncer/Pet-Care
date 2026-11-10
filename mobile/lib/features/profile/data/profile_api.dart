import 'package:dio/dio.dart';

import '../domain/user_profile.dart';

/// Appels réseau liés au profil de l'utilisateur connecté.
///
/// On réutilise l'instance `dio` globale (configurée avec baseUrl + intercepteur
/// JWT dans `core/network`). Le token est donc ajouté automatiquement : ces routes
/// sont protégées (utilisateur authentifié).
class ProfileApi {
  ProfileApi(this._dio);
  final Dio _dio;

  /// GET /users/me → profil courant.
  Future<UserProfile> fetchMe() async {
    final response = await _dio.get('/users/me');
    // L'API enveloppe tout dans { success, data, message } → on prend `data`.
    final data = response.data['data'] as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  /// PUT /users/me → met à jour prénom / nom / téléphone.
  /// Renvoie le profil mis à jour (l'API renvoie l'objet complet).
  Future<UserProfile> updateMe({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final response = await _dio.put('/users/me', data: {
      'firstName': firstName,
      'lastName': lastName,
      // On n'envoie `phone` que s'il est renseigné (évite d'écraser avec null).
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }
}