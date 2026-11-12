import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../data/agenda_api.dart';
import '../data/agenda_notifications.dart';
import '../domain/agenda_item.dart';

/// Fournit l'API Agenda.
final agendaApiProvider =
Provider<AgendaApi>((ref) => AgendaApi(ref.watch(dioProvider)));

/// Service de notifications locales (une seule instance pour toute l'app).
final agendaNotificationsProvider =
Provider<AgendaNotifications>((ref) => AgendaNotifications());

/// Liste des éléments d'agenda du propriétaire courant (chargement asynchrone).
final agendaListProvider =
AsyncNotifierProvider<AgendaListNotifier, List<AgendaItem>>(
    AgendaListNotifier.new);

class AgendaListNotifier extends AsyncNotifier<List<AgendaItem>> {
  @override
  Future<List<AgendaItem>> build() {
    ref.watch(agendaApiProvider);
    return _load();
  }

  /// Charge la liste puis reprogramme les notifications (sans bloquer l'écran).
  Future<List<AgendaItem>> _load() async {
    final items = await ref.read(agendaApiProvider).list();
    unawaited(ref.read(agendaNotificationsProvider).sync(items));
    return items;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  /// Active / désactive les notifications de rappel (interrupteur de l'écran).
  Future<void> setRemindersEnabled(bool enabled) async {
    final notifications = ref.read(agendaNotificationsProvider);
    notifications.enabled = enabled;
    await notifications.sync(state.valueOrNull ?? const []);
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