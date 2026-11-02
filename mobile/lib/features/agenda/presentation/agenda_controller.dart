import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../data/agenda_api.dart';
import '../domain/agenda_item.dart';

/// Fournit l'API Agenda.
final agendaApiProvider =
Provider<AgendaApi>((ref) => AgendaApi(ref.watch(dioProvider)));

/// Liste des éléments d'agenda du propriétaire courant (chargement asynchrone).
final agendaListProvider =
AsyncNotifierProvider<AgendaListNotifier, List<AgendaItem>>(AgendaListNotifier.new);

class AgendaListNotifier extends AsyncNotifier<List<AgendaItem>> {
  @override
  Future<List<AgendaItem>> build() => ref.watch(agendaApiProvider).list();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(agendaApiProvider).list());
  }

  Future<void> create(Map<String, dynamic> body) async {
    await ref.read(agendaApiProvider).create(body);
    await refresh();
  }

  Future<void> updateItem(String id, Map<String, dynamic> body) async {
    await ref.read(agendaApiProvider).update(id, body);
    await refresh();
  }

  Future<void> updateStatus(String id, String status) async {
    await ref.read(agendaApiProvider).updateStatus(id, status);
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(agendaApiProvider).delete(id);
    await refresh();
  }
}