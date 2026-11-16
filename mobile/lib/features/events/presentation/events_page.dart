import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/pet_event.dart';
import 'event_detail_page.dart';
import 'event_form_page.dart';
import 'event_ui.dart';
import 'events_controller.dart';

/// Écran principal du module : événements à venir (filtrables par type) et
/// mes inscriptions. L'admin dispose d'un bouton de création.
class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(authControllerProvider).state.user?.isAdmin ?? false;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTokens.scaffold,
        appBar: AppBar(
          backgroundColor: AppTokens.scaffold,
          foregroundColor: AppTokens.textStrong,
          elevation: 0,
          title: const Text('Événements', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: AppTokens.primary,
            indicatorColor: AppTokens.primary,
            unselectedLabelColor: AppTokens.textMuted,
            tabs: [
              Tab(text: 'À venir'),
              Tab(text: 'Mes inscriptions'),
            ],
          ),
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                backgroundColor: AppTokens.primary,
                foregroundColor: Colors.white,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EventFormPage()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Créer'),
              )
            : null,
        body: const TabBarView(
          children: [_UpcomingTab(), _MyEventsTab()],
        ),
      ),
    );
  }
}

class _UpcomingTab extends ConsumerWidget {
  const _UpcomingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(eventTypeFilterProvider);
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            children: [
              _FilterChip(
                label: 'Tous',
                selected: selectedType == null,
                onTap: () => ref.read(eventTypeFilterProvider.notifier).state = null,
              ),
              for (final entry in eventTypeShortLabels.entries)
                _FilterChip(
                  label: entry.value,
                  icon: eventTypeIcon(entry.key),
                  selected: selectedType == entry.key,
                  onTap: () => ref.read(eventTypeFilterProvider.notifier).state = entry.key,
                ),
            ],
          ),
        ),
        Expanded(
          child: AsyncView<List<PetEvent>>(
            value: eventsAsync,
            onRetry: () => ref.invalidate(upcomingEventsProvider),
            data: (events) => RefreshIndicator(
              onRefresh: () => ref.refresh(upcomingEventsProvider.future),
              child: events.isEmpty
                  ? _EmptyState(
                      icon: Icons.event_busy,
                      text: selectedType == null
                          ? 'Aucun événement à venir pour le moment.'
                          : 'Aucun événement « ${eventTypeLabel(selectedType)} » à venir.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => EventCard(event: events[i]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MyEventsTab extends ConsumerWidget {
  const _MyEventsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAsync = ref.watch(myEventsProvider);
    return AsyncView<List<PetEvent>>(
      value: myAsync,
      onRetry: () => ref.invalidate(myEventsProvider),
      data: (events) {
        final upcoming = events.where((e) => !e.hasStarted()).toList();
        final past = events.where((e) => e.hasStarted()).toList();
        return RefreshIndicator(
          onRefresh: () => ref.refresh(myEventsProvider.future),
          child: events.isEmpty
              ? const _EmptyState(
                  icon: Icons.how_to_reg,
                  text: "Vous n'êtes inscrit à aucun événement.\n"
                      "Parcourez l'onglet « À venir » pour participer avec votre compagnon.",
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  children: [
                    if (upcoming.isNotEmpty) ...[
                      _SectionTitle('À venir (${upcoming.length})'),
                      for (final e in upcoming) ...[EventCard(event: e), const SizedBox(height: 12)],
                    ],
                    if (past.isNotEmpty) ...[
                      _SectionTitle('Passés (${past.length})'),
                      for (final e in past) ...[
                        EventCard(event: e, dimmed: true),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ],
                ),
        );
      },
    );
  }
}

/// Carte d'un événement dans les listes.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.dimmed = false});

  final PetEvent event;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final color = eventTypeColor(event.type);
    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EventDetailPage(eventId: event.id)),
          ),
          child: Ink(
            decoration: AppTokens.cardDecoration,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateBlock(date: event.startAt, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: EventTypeBadge(event.type)),
                          if (event.registered) ...[
                            const SizedBox(width: 6),
                            const _RegisteredPill(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.textStrong,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _IconLine(Icons.schedule, formatEventWhen(event)),
                      _IconLine(Icons.place_outlined, event.location),
                      const SizedBox(height: 8),
                      CapacityBar(event, dense: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.date, required this.color});
  final DateTime date;
  final Color color;

  static const _moisCourts = [
    'JANV', 'FÉVR', 'MARS', 'AVR', 'MAI', 'JUIN',
    'JUIL', 'AOÛT', 'SEPT', 'OCT', 'NOV', 'DÉC',
  ];

  @override
  Widget build(BuildContext context) {
    final l = date.toLocal();
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${l.day}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            _moisCourts[l.month - 1],
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _RegisteredPill extends StatelessWidget {
  const _RegisteredPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTokens.mint,
        borderRadius: BorderRadius.circular(AppTokens.chipRadius),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 13, color: AppTokens.primary),
          SizedBox(width: 3),
          Text(
            'Inscrit',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTokens.primary),
          ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppTokens.textMuted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppTokens.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        avatar: icon == null
            ? null
            : Icon(icon, size: 16, color: selected ? Colors.white : AppTokens.textMuted),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        selectedColor: AppTokens.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppTokens.textStrong,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: selected ? AppTokens.primary : AppTokens.border),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTokens.textStrong),
      ),
    );
  }
}

/// État vide « scrollable » pour garder le tirer-pour-rafraîchir.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 56, color: AppTokens.textMuted),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTokens.textMuted, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
