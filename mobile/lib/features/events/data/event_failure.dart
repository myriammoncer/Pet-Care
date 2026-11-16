/// Erreur du module Événements, avec un message lisible (repris du backend
/// quand il en fournit un). Propre au module : ne dépend pas de `core/error`.
class EventFailure implements Exception {
  const EventFailure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
