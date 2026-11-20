import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../data/events_api.dart';
import '../domain/pet_event.dart';

/// Fournit l'API Événements.
final eventsApiProvider = Provider<EventsApi>((ref) => EventsApi(ref.watch(dioProvider)));

/// Filtre de type sélectionné sur l'écran (null = tous).
final eventTypeFilterProvider = StateProvider<String?>((ref) => null);

/// Événements à venir (filtrés par type).
/// `autoDispose` : rien n'est gardé en cache après la déconnexion (les champs
/// `registered` / `myPetId` dépendent de l'utilisateur connecté).
final upcomingEventsProvider = FutureProvider.autoDispose<List<PetEvent>>((ref) {
  final type = ref.watch(eventTypeFilterProvider);
  return ref.watch(eventsApiProvider).list(type: type);
});

/// Mes inscriptions (à venir puis passées).
final myEventsProvider = FutureProvider.autoDispose<List<PetEvent>>((ref) {
  return ref.watch(eventsApiProvider).myRegistrations();
});

/// Détail d'un événement.
final eventDetailProvider = FutureProvider.autoDispose.family<PetEvent, String>((ref, id) {
  return ref.watch(eventsApiProvider).getById(id);
});

/// Participants d'un événement (admin uniquement).
final eventParticipantsProvider =
    FutureProvider.autoDispose.family<List<EventParticipant>, String>((ref, id) {
  return ref.watch(eventsApiProvider).participants(id);
});

/// Actions (inscription, CRUD admin) : appellent l'API puis rafraîchissent les vues.
final eventsActionsProvider = Provider<EventsActions>((ref) => EventsActions(ref));

class EventsActions {
  EventsActions(this._ref);
  final Ref _ref;

  EventsApi get _api => _ref.read(eventsApiProvider);

  Future<void> register(String eventId, String petId) async {
    await _api.register(eventId, petId);
    _refresh(eventId);
  }

  Future<void> unregister(String eventId) async {
    await _api.unregister(eventId);
    _refresh(eventId);
  }

  Future<void> create(Map<String, dynamic> body) async {
    await _api.create(body);
    _refresh();
  }

  Future<void> update(String eventId, Map<String, dynamic> body) async {
    await _api.update(eventId, body);
    _refresh(eventId);
  }

  Future<void> delete(String eventId) async {
    await _api.delete(eventId);
    _refresh();
  }

  Future<void> removeParticipant(String eventId, String userId) async {
    await _api.removeParticipant(eventId, userId);
    _refresh(eventId);
  }

  void _refresh([String? eventId]) {
    _ref.invalidate(upcomingEventsProvider);
    _ref.invalidate(myEventsProvider);
    if (eventId != null) {
      _ref.invalidate(eventDetailProvider(eventId));
      _ref.invalidate(eventParticipantsProvider(eventId));
    }
  }
}
