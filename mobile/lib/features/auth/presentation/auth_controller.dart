import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/network/token_storage.dart';
import '../data/auth_api.dart';
import '../domain/auth_user.dart';

/// État d'authentification exposé à l'UI et au routeur.
class AuthState {
  const AuthState({this.user, this.loading = false, this.error});

  final AuthUser? user;
  final bool loading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({AuthUser? user, bool? loading, String? error, bool clearError = false}) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Contrôleur d'authentification. ChangeNotifier pour servir de
/// `refreshListenable` à go_router.
class AuthController extends ChangeNotifier {
  AuthController(this._api, this._storage);

  final AuthApi _api;
  final TokenStorage _storage;

  AuthState _state = const AuthState();
  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;

  void _set(AuthState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _set(_state.copyWith(loading: true, clearError: true));
    try {
      final result = await _api.login(email, password);
      await _storage.saveTokens(access: result.accessToken, refresh: result.refreshToken);
      _set(AuthState(user: result.user));
    } catch (_) {
      _set(const AuthState(error: 'Email ou mot de passe invalide'));
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    _set(_state.copyWith(loading: true, clearError: true));
    try {
      final result = await _api.signup(
        email: email, password: password,
        firstName: firstName, lastName: lastName, role: role,
      );
      await _storage.saveTokens(access: result.accessToken, refresh: result.refreshToken);
      _set(AuthState(user: result.user));
    } catch (_) {
      _set(const AuthState(error: "Échec de l'inscription (email déjà utilisé ?)"));
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    _set(const AuthState());
  }
}

/// Expose le contrôleur. `.notifier` donne le ChangeNotifier pour go_router.
final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(
    AuthApi(ref.watch(dioProvider)),
    ref.watch(tokenStorageProvider),
  );
});
