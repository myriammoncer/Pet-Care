import 'package:flutter/foundation.dart';

/// Configuration de l'application selon l'environnement (flavor) ET la plateforme.
///
/// L'URL de base de l'API change selon la cible de test :
/// - Web / iOS / desktop        → http://localhost:8080
/// - Émulateur Android          → http://10.0.2.2:8080 (10.0.2.2 = localhost de l'hôte)
class AppConfig {
  const AppConfig({required this.flavor, required this.apiBaseUrl});

  final String flavor;
  final String apiBaseUrl;

  /// Environnement de développement (URL calculée selon la plateforme).
  static AppConfig get dev => AppConfig(flavor: 'dev', apiBaseUrl: _devBaseUrl());

  /// Environnement de production.
  static const AppConfig prod = AppConfig(
    flavor: 'prod',
    apiBaseUrl: 'https://api.petcare.app/api/v1',
  );

  static String _devBaseUrl() {
    const port = 8080;
    // Web (Chrome) : on vise localhost.
    if (kIsWeb) return 'http://localhost:$port/api/v1';
    // Émulateur Android : 10.0.2.2 pointe vers la machine hôte.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$port/api/v1';
    }
    // iOS / desktop : localhost.
    return 'http://localhost:$port/api/v1';
  }
}