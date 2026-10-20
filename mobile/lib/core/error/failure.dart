/// Représentation typée d'une erreur côté application (découplée de dio).
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Erreur réseau / serveur (timeout, 5xx, pas de connexion).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur réseau, réessayez plus tard']);
}

/// Identifiants invalides ou session expirée (401).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expirée, reconnectez-vous']);
}

/// Accès refusé (403).
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Accès refusé']);
}

/// Ressource introuvable (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable']);
}

/// Erreur de validation ou de requête (400 / 409).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Requête invalide']);
}

/// Erreur inattendue.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Une erreur est survenue']);
}
