import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/token_storage.dart';

/// Providers transverses (infrastructure) injectés dans toute l'application.

/// Configuration active (surchargée au démarrage dans main.dart selon le flavor).
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.dev);

/// Stockage sécurisé des tokens JWT.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// Client HTTP configuré (base URL + intercepteur JWT).
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ref.watch(appConfigProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Instance `dio` prête à l'emploi pour les data sources.
final dioProvider = Provider<Dio>((ref) => ref.watch(apiClientProvider).dio);
