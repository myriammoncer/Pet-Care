import 'package:flutter/foundation.dart'; // Indispensable pour kIsWeb

/// Configuration de l'application selon l'environnement (flavor).
///
/// L'URL de base de l'API change selon la cible :
/// - émulateur Android : 10.0.2.2 (= localhost de la machine hôte)
/// - simulateur iOS / web : localhost
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
  });

  final String flavor;
  final String apiBaseUrl;

  /// Environnement de développement (par défaut).
  static AppConfig get dev => AppConfig(
    flavor: 'dev',
    // Détection automatique selon la plateforme :
    // - Web (Chrome) -> localhost
    // - Émulateur Android -> 10.0.2.2
    apiBaseUrl: kIsWeb
        ? 'http://localhost:8080/api/v1'
        : 'http://10.0.2.2:8080/api/v1',
  );

  /// Environnement de production.
  static const AppConfig prod = AppConfig(
    flavor: 'prod',
    apiBaseUrl: 'https://api.petcare.app/api/v1',
  );
}