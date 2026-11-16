import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../pets/domain/pet.dart';
import '../../pets/presentation/pets_controller.dart';
import '../domain/pet_event.dart';
import 'event_form_page.dart';
import 'event_registration.dart';
import 'event_ui.dart';
import 'events_colors.dart';
import 'events_controller.dart';

/// Détail d'un événement : infos, places, inscription avec un animal,
/// désinscription ; pour l'admin : modification, suppression, participants.
class EventDetailPage extends ConsumerStatefulWidget {
  const EventDetailPage({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) showEventSnack(context, successMessage);
    } catch (e) {
      if (mounted) showEventSnack(context, errorText(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register(PetEvent event) async {
    setState(() => _busy = true);
    await registerWithPet(context, ref, event);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _unregister(PetEvent event) async {
    final ok = await _confirm(
      title: 'Se désinscrire ?',
      message: 'Votre place pour « ${event.title} » sera libérée.',
      confirmLabel: 'Me désinscrire',
    );
    if (!ok) return;
    await _run(() => ref.read(eventsActionsProvider).unregister(event.id), 'Désinscription effectuée');
  }

  Future<void> _delete(PetEvent event) async {
    final ok = await _confirm(
      title: "Supprimer l'événement ?",
      message: '« ${event.title} » et ses ${event.registeredCount} inscription(s) seront supprimés.',
      confirmLabel: 'Supprimer',
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(eventsActionsProvider).delete(event.id);
      if (!mounted) return;
      showEventSnack(context, 'Événement supprimé');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      showEventSnack(context, errorText(e), error: true);
    }
  }

  Future<void> _removeParticipant(PetEvent event, EventParticipant p) async {
    final ok = await _confirm(
      title: 'Retirer ce participant ?',
      message: '${p.userName ?? p.userEmail ?? p.userId} sera désinscrit de « ${event.title} ».',
      confirmLabel: 'Retirer',
    );
    if (!ok) return;
    await _run(
      () => ref.read(eventsActionsProvider).removeParticipant(event.id, p.userId),
      'Participant retiré',
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: EventsColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final isAdmin = ref.watch(authControllerProvider).state.user?.isAdmin ?? false;
    final event = eventAsync.valueOrNull;

    return Scaffold(
      backgroundColor: EventsColors.background,
      appBar: AppBar(
        backgroundColor: EventsColors.background,
        foregroundColor: EventsColors.textStrong,
        elevation: 0,
        title: const Text("Détail de l'événement"),
        actions: [
          if (isAdmin && event != null) ...[
            IconButton(
              tooltip: 'Modifier',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
                      ),
            ),
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy ? null : () => _delete(event),
            ),
          ],
        ],
      ),
      bottomNavigationBar: event == null ? null : _ActionBar(
        event: event,
        busy: _busy,
        onRegister: () => _register(event),
        onUnregister: () => _unregister(event),
      ),
      body: AsyncView<PetEvent>(
        value: eventAsync,
        onRetry: () => ref.invalidate(eventDetailProvider(widget.eventId)),
        data: (e) => RefreshIndicator(
          onRefresh: () => ref.refresh(eventDetailProvider(widget.eventId).future),
          child: ListView(
            padding: const EdgeInsets.all(EventsColors.gap),
            children: [
              _Header(event: e),
              const SizedBox(height: 12),
              if (e.registered) ...[
                _MyRegistrationCard(event: e),
                const SizedBox(height: 12),
              ],
              if ((e.description ?? '').trim().isNotEmpty) ...[
                _Card(
                  title: 'Description',
                  child: Text(e.description!.trim(), style: const TextStyle(height: 1.4)),
                ),
                const SizedBox(height: 12),
              ],
              if (isAdmin) _ParticipantsCard(event: e, onRemove: (p) => _removeParticipant(e, p)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event});
  final PetEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: EventsColors.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: Image.asset(eventTypeImage(event.type), fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(EventsColors.gap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventTypeBadge(event.type),
                const SizedBox(height: 10),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: EventsColors.textStrong,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.calendar_today_outlined, text: formatEventWhen(event)),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.place_outlined, text: event.location),
                const SizedBox(height: 14),
                CapacityBar(event),
                if (event.hasStarted()) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Cet événement a commencé ou est terminé : inscriptions closes.',
                    style: TextStyle(color: EventsColors.textMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rappel « vous participez avec <animal> ».
class _MyRegistrationCard extends ConsumerWidget {
  const _MyRegistrationCard({required this.event});
  final PetEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsListProvider).valueOrNull ?? const <Pet>[];
    final petName = pets.where((p) => p.id == event.myPetId).map((p) => p.name).firstOrNull;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EventsColors.mint,
        borderRadius: BorderRadius.circular(EventsColors.radius),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: EventsColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              petName == null ? 'Vous êtes inscrit à cet événement.' : 'Vous participez avec $petName.',
              style: const TextStyle(fontWeight: FontWeight.w600, color: EventsColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsCard extends ConsumerWidget {
  const _ParticipantsCard({required this.event, required this.onRemove});
  final PetEvent event;
  final void Function(EventParticipant) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(eventParticipantsProvider(event.id));
    return _Card(
      title: 'Participants (${event.registeredCount}/${event.capacity})',
      child: participantsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: LinearProgressIndicator(),
        ),
        error: (e, _) => Text(errorText(e), style: const TextStyle(color: EventsColors.danger)),
        data: (participants) {
          if (participants.isEmpty) {
            return const Text('Aucun inscrit pour le moment.',
                style: TextStyle(color: EventsColors.textMuted));
          }
          return Column(
            children: [
              for (final p in participants)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: EventsColors.mint,
                    child: Icon(Icons.person, color: EventsColors.primary),
                  ),
                  title: Text(p.userName?.isNotEmpty == true ? p.userName! : (p.userEmail ?? p.userId)),
                  subtitle: Text([
                    if (p.petName != null) '🐾 ${p.petName}',
                    if (p.registeredAt != null) 'inscrit le ${formatDay(p.registeredAt!)}',
                  ].join(' · ')),
                  trailing: IconButton(
                    tooltip: 'Retirer',
                    icon: const Icon(Icons.person_remove_outlined, color: EventsColors.danger),
                    onPressed: () => onRemove(p),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Barre d'action en bas d'écran : S'inscrire / Se désinscrire / état.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.event,
    required this.busy,
    required this.onRegister,
    required this.onUnregister,
  });

  final PetEvent event;
  final bool busy;
  final VoidCallback onRegister;
  final VoidCallback onUnregister;

  @override
  Widget build(BuildContext context) {
    Widget button;
    if (event.canUnregister) {
      button = OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: EventsColors.danger,
          side: const BorderSide(color: EventsColors.danger),
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: busy ? null : onUnregister,
        icon: const Icon(Icons.event_busy),
        label: const Text('Se désinscrire'),
      );
    } else if (event.canRegister) {
      button = FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: EventsColors.primary,
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: busy ? null : onRegister,
        icon: const Icon(Icons.pets),
        label: const Text("S'inscrire avec mon animal"),
      );
    } else {
      final label = event.registered
          ? 'Inscrit · événement commencé'
          : event.hasStarted()
              ? 'Inscriptions closes'
              : 'Complet';
      button = FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: null,
        child: Text(label),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: busy
            ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()))
            : button,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: EventsColors.cardDecoration,
      padding: const EdgeInsets.all(EventsColors.gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: EventsColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}
