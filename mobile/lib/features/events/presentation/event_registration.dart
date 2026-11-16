import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pets/domain/pet.dart';
import '../../pets/presentation/pets_controller.dart';
import '../domain/pet_event.dart';
import 'event_ui.dart';
import 'events_colors.dart';
import 'events_controller.dart';

/// Ouvre le choix de l'animal puis inscrit l'utilisateur.
/// Utilisé depuis la liste (bouton « S'inscrire ») et depuis le détail.
/// Renvoie `true` si l'inscription a réussi.
Future<bool> registerWithPet(BuildContext context, WidgetRef ref, PetEvent event) async {
  final pet = await showModalBottomSheet<Pet>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: EventsColors.card,
    builder: (_) => const PetPickerSheet(),
  );
  if (pet == null || !context.mounted) return false;
  try {
    await ref.read(eventsActionsProvider).register(event.id, pet.id);
    if (context.mounted) showEventSnack(context, 'Inscription confirmée avec ${pet.name} 🎉');
    return true;
  } catch (e) {
    if (context.mounted) showEventSnack(context, errorText(e), error: true);
    return false;
  }
}

/// Feuille de choix de l'animal pour l'inscription.
class PetPickerSheet extends ConsumerWidget {
  const PetPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsListProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avec quel compagnon participez-vous ?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: EventsColors.textStrong,
              ),
            ),
            const SizedBox(height: 12),
            petsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(errorText(e)),
              data: (pets) {
                if (pets.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Ajoutez d'abord un animal dans l'onglet « Animaux » pour pouvoir vous inscrire.",
                      style: TextStyle(color: EventsColors.textMuted),
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final pet in pets)
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: EventsColors.mint,
                            child: Icon(Icons.pets, color: EventsColors.primary),
                          ),
                          title: Text(pet.name),
                          subtitle: pet.breed == null ? null : Text(pet.breed!),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.pop(context, pet),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
