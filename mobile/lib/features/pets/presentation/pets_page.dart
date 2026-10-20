import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_view.dart';
import '../../auth/presentation/auth_controller.dart';
import 'pets_controller.dart';

class PetsPage extends ConsumerWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes animaux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => ref.read(authControllerProvider).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(petsListProvider.notifier).refresh(),
        child: AsyncView(
          value: petsAsync,
          onRetry: () => ref.read(petsListProvider.notifier).refresh(),
          data: (pets) {
            if (pets.isEmpty) {
              return const Center(child: Text('Aucun animal. Ajoutez-en un !'));
            }
            return ListView.separated(
              itemCount: pets.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final pet = pets[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: pet.photoUrl != null ? NetworkImage(pet.photoUrl!) : null,
                    child: pet.photoUrl == null ? const Icon(Icons.pets) : null,
                  ),
                  title: Text(pet.name),
                  subtitle: Text('${pet.species}${pet.breed != null ? ' · ${pet.breed}' : ''}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/pets/${pet.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    String species = 'DOG';
    String sex = 'MALE';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvel animal'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: species,
                decoration: const InputDecoration(labelText: 'Espèce'),
                items: const [
                  DropdownMenuItem(value: 'DOG', child: Text('Chien')),
                  DropdownMenuItem(value: 'CAT', child: Text('Chat')),
                  DropdownMenuItem(value: 'BIRD', child: Text('Oiseau')),
                  DropdownMenuItem(value: 'RABBIT', child: Text('Lapin')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => species = v ?? 'DOG'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: sex,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: const [
                  DropdownMenuItem(value: 'MALE', child: Text('Mâle')),
                  DropdownMenuItem(value: 'FEMALE', child: Text('Femelle')),
                  DropdownMenuItem(value: 'UNKNOWN', child: Text('Inconnu')),
                ],
                onChanged: (v) => setState(() => sex = v ?? 'MALE'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await ref.read(petsListProvider.notifier).create({
                'name': nameController.text.trim(),
                'species': species,
                'sex': sex,
                'status': 'HEALTHY',
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
