import 'package:dio/dio.dart';

import '../../../core/error/failure.dart';
import '../domain/pet_event.dart';

/// Appels réseau du module Événements (contrat : docs/API.md#module-événements).
/// Les erreurs dio sont converties en [Failure] avec le message du backend.
class EventsApi {
  EventsApi(this._dio);
  final Dio _dio;

  /// GET /events — à venir par défaut, filtres optionnels.
  Future<List<PetEvent>> list({String? type, DateTime? from, DateTime? to, int size = 50}) {
    return _guard(() async {
      final query = <String, dynamic>{'size': size, 'sort': 'startAt,asc'};
      if (type != null) query['type'] = type;
      if (from != null) query['from'] = from.toUtc().toIso8601String();
      if (to != null) query['to'] = to.toUtc().toIso8601String();
      final response = await _dio.get('/events', queryParameters: query);
      final content = response.data['data']['content'] as List<dynamic>;
      return content.map((e) => PetEvent.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// GET /events/me — mes inscriptions.
  Future<List<PetEvent>> myRegistrations() {
    return _guard(() async {
      final response = await _dio.get('/events/me');
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => PetEvent.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<PetEvent> getById(String id) => _guard(() async {
        final response = await _dio.get('/events/$id');
        return _event(response);
      });

  Future<PetEvent> create(Map<String, dynamic> body) => _guard(() async {
        final response = await _dio.post('/events', data: body);
        return _event(response);
      });

  Future<PetEvent> update(String id, Map<String, dynamic> body) => _guard(() async {
        final response = await _dio.put('/events/$id', data: body);
        return _event(response);
      });

  Future<void> delete(String id) => _guard(() => _dio.delete('/events/$id'));

  Future<PetEvent> register(String id, String petId) => _guard(() async {
        final response = await _dio.post('/events/$id/register', data: {'petId': petId});
        return _event(response);
      });

  Future<PetEvent> unregister(String id) => _guard(() async {
        final response = await _dio.delete('/events/$id/register');
        return _event(response);
      });

  /// GET /events/{id}/participants (admin).
  Future<List<EventParticipant>> participants(String id) => _guard(() async {
        final response = await _dio.get('/events/$id/participants');
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((e) => EventParticipant.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  /// DELETE /events/{id}/participants/{userId} (admin).
  Future<PetEvent> removeParticipant(String id, String userId) => _guard(() async {
        final response = await _dio.delete('/events/$id/participants/$userId');
        return _event(response);
      });

  PetEvent _event(Response<dynamic> response) =>
      PetEvent.fromJson(response.data['data'] as Map<String, dynamic>);

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  /// Convertit une erreur dio en [Failure] en reprenant le message du backend
  /// (`{ success: false, error: { code, message, details } }`).
  static Failure _toFailure(DioException e) {
    final status = e.response?.statusCode;
    String? serverMessage;
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final error = data['error'] as Map;
      final details = error['details'];
      serverMessage = (details is List && details.isNotEmpty)
          ? details.join('\n')
          : error['message'] as String?;
    }
    if (status == null) return const NetworkFailure();
    if (status == 400 || status == 409) {
      return ValidationFailure(serverMessage ?? 'Requête invalide');
    }
    if (status == 401) return const UnauthorizedFailure();
    if (status == 403) return ForbiddenFailure(serverMessage ?? 'Accès refusé');
    if (status == 404) return NotFoundFailure(serverMessage ?? 'Ressource introuvable');
    if (status >= 500) return const NetworkFailure();
    return UnexpectedFailure(serverMessage ?? 'Une erreur est survenue');
  }
}
