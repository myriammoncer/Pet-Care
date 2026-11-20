import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_view.dart';
import '../domain/pet_event.dart';
import 'events_colors.dart';
import 'events_controller.dart';
import 'events_page.dart';

/// Mes inscriptions : événements à venir puis passés.
class MyEventsPage extends ConsumerWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAsync = ref.watch(myEventsProvider);
    return Scaffold(
      backgroundColor: EventsColors.background,
      appBar: AppBar(
        backgroundColor: EventsColors.background,
        foregroundColor: EventsColors.textStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Mes inscriptions', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: AsyncView<List<PetEvent>>(
        value: myAsync,
        onRetry: () => ref.invalidate(myEventsProvider),
        data: (events) {
          final upcoming = events.where((e) => !e.hasStarted()).toList();
          final past = events.where((e) => e.hasStarted()).toList();
          return RefreshIndicator(
            color: EventsColors.primary,
            onRefresh: () => ref.refresh(myEventsProvider.future),
            child: events.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Icon(Icons.how_to_reg, size: 56, color: EventsColors.textMuted),
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "Vous n'êtes inscrit à aucun événement.\n"
                          'Choisissez un rendez-vous et participez avec votre compagnon.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: EventsColors.textMuted, fontSize: 15),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        _SectionTitle('À venir (${upcoming.length})'),
                        for (final e in upcoming) ...[EventListCard(event: e), const SizedBox(height: 8)],
                      ],
                      if (past.isNotEmpty) ...[
                        _SectionTitle('Passés (${past.length})'),
                        for (final e in past) ...[
                          EventListCard(event: e, dimmed: true),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ],
                  ),
          );
        },
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
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: EventsColors.textStrong),
      ),
    );
  }
}
