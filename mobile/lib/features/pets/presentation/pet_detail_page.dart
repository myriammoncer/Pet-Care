import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_view.dart';
import 'pets_controller.dart';

class PetDetailPage extends ConsumerWidget {
  const PetDetailPage({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petDetailProvider(petId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets'),
        ),
        title: const Text('Fiche animal'),
      ),
      body: AsyncView(
        value: petAsync,
        onRetry: () => ref.invalidate(petDetailProvider(petId)),
        data: (pet) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: pet.photoUrl != null ? NetworkImage(pet.photoUrl!) : null,
                child: pet.photoUrl == null ? const Icon(Icons.pets, size: 48) : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(pet.name, style: Theme.of(context).textTheme.headlineSmall)),
            const SizedBox(height: 24),
            _row('Espèce', pet.species),
            if (pet.breed != null) _row('Race', pet.breed!),
            if (pet.ageYears != null) _row('Âge', '${pet.ageYears} an(s)'),
            if (pet.sex != null) _row('Sexe', pet.sex!),
            if (pet.weight != null) _row('Poids', '${pet.weight} kg'),
            if (pet.color != null) _row('Couleur', pet.color!),
            if (pet.microchipNumber != null) _row('Puce', pet.microchipNumber!),
            if (pet.status != null) _row('Statut', pet.status!),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/pets/$petId/medical'),
              icon: const Icon(Icons.medical_services),
              label: const Text('Dossier médical'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(value),
          ],
        ),
      );
}
