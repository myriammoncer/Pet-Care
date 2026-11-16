import 'package:dio/dio.dart';

import '../domain/agenda_item.dart';

/// Appels réseau du module Agenda (contrat défini dans docs/API.md).
class AgendaApi {
  AgendaApi(this._dio);
  final Dio _dio;

  /// GET /agenda avec filtres optionnels (petId, type, période from/to).
  Future<List<AgendaItem>> list({
    String? petId,
    String? type,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String, dynamic>{};
    if (petId != null) query['petId'] = petId;
    if (type != null) query['type'] = type;
    if (from != null) query['from'] = from.toUtc().toIso8601String();
    if (to != null) query['to'] = to.toUtc().toIso8601String();

    final response = await _dio.get('/agenda', queryParameters: query);
    final content = response.data['data']['content'] as List<dynamic>;
    return content
        .map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AgendaItem> getById(String id) async {
    final response = await _dio.get('/agenda/$id');
    return AgendaItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AgendaItem> create(Map<String, dynamic> body) async {
    final response = await _dio.post('/agenda', data: body);
    return AgendaItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AgendaItem> update(String id, Map<String, dynamic> body) async {
    final response = await _dio.put('/agenda/$id', data: body);
    return AgendaItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// PATCH /agenda/{id}/status — marquer DONE / CANCELLED / MISSED.
  Future<AgendaItem> updateStatus(String id, String status) async {
    final response = await _dio.patch('/agenda/$id/status', data: {'status': status});
    return AgendaItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _dio.delete('/agenda/$id');
}