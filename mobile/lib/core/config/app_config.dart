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
  static const AppConfig dev = AppConfig(
    flavor: 'dev',
    // Adapter selon la plateforme de test ; 10.0.2.2 pour l'émulateur Android.
    apiBaseUrl: 'http://10.0.2.2:8080/api/v1',
  );

  /// Environnement de production.
  static const AppConfig prod = AppConfig(
    flavor: 'prod',
    apiBaseUrl: 'https://api.petcare.app/api/v1',
  );
}
