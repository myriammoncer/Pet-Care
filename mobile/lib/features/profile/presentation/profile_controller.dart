import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart'; // dioProvider
import '../data/profile_api.dart';
import '../domain/user_profile.dart';

/// Fournit l'instance ProfileApi (injecte le `dio` global).
final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref.watch(dioProvider));
});

/// État asynchrone du profil : charge `GET /users/me` au premier accès.
///
/// `AsyncNotifier` gère automatiquement les états loading / data / error,
/// consommés à l'UI via `AsyncValue` (voir widget AsyncView du socle).
class ProfileController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() {
    // Appelé une fois ; le résultat est mis en cache par Riverpod.
    return ref.watch(profileApiProvider).fetchMe();
  }

  /// Met à jour le profil puis rafraîchit l'état avec la valeur renvoyée.
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    // Passe l'UI en "loading" pendant l'appel réseau.
    state = const AsyncValue.loading();
    // `guard` capture les exceptions et place l'état en error le cas échéant.
    state = await AsyncValue.guard(() {
      return ref.read(profileApiProvider).updateMe(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
    });
  }

  /// Force un rechargement depuis l'API (ex. après un pull-to-refresh).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(profileApiProvider).fetchMe());
  }
}

/// Provider exposé à l'UI.
final profileControllerProvider =
AsyncNotifierProvider<ProfileController, UserProfile>(ProfileController.new);