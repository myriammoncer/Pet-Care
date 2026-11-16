import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Rend un [AsyncValue] en gérant uniformément les états
/// chargement / erreur / données avec gestion conviviale des erreurs d'authentification.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.data, this.onRetry});

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final isAuthError = e is DioException &&
            (e.response?.statusCode == 401 || e.response?.statusCode == 403);

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAuthError ? Icons.lock_outline : Icons.error_outline,
                  size: 48,
                  color: isAuthError
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  isAuthError ? 'Connexion requise' : 'Erreur de chargement',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAuthError
                      ? 'Votre session a expiré ou une authentification est requise pour accéder à ces données.'
                      : '$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (isAuthError)
                      FilledButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.login),
                        label: const Text('Se connecter'),
                      ),
                    if (onRetry != null)
                      OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      data: data,
    );
  }
}
