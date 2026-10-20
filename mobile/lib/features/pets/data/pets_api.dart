import 'package:dio/dio.dart';

import '../domain/pet.dart';

/// Appels réseau du module Pets.
class PetsApi {
  PetsApi(this._dio);
  final Dio _dio;

  Future<List<Pet>> list() async {
    final response = await _dio.get('/pets');
    final content = response.data['data']['content'] as List<dynamic>;
    return content.map((e) => Pet.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Pet> getById(String id) async {
    final response = await _dio.get('/pets/$id');
    return Pet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Pet> create(Map<String, dynamic> body) async {
    final response = await _dio.post('/pets', data: body);
    return Pet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _dio.delete('/pets/$id');
}
