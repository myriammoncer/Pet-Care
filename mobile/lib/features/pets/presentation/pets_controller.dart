import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../data/pets_api.dart';
import '../domain/pet.dart';

/// Fournit l'API Pets.
final petsApiProvider = Provider<PetsApi>((ref) => PetsApi(ref.watch(dioProvider)));

/// Liste des animaux du propriétaire courant (chargement asynchrone).
final petsListProvider = AsyncNotifierProvider<PetsListNotifier, List<Pet>>(PetsListNotifier.new);

class PetsListNotifier extends AsyncNotifier<List<Pet>> {
  @override
  Future<List<Pet>> build() => ref.watch(petsApiProvider).list();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(petsApiProvider).list());
  }

  Future<void> create(Map<String, dynamic> body) async {
    await ref.read(petsApiProvider).create(body);
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(petsApiProvider).delete(id);
    await refresh();
  }
}

/// Détail d'un animal par identifiant.
final petDetailProvider = FutureProvider.family<Pet, String>((ref, id) {
  return ref.watch(petsApiProvider).getById(id);
});
