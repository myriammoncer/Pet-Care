import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/widgets/async_view.dart';

/// Récupère les événements à venir.
final eventsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/events');
  final content = response.data['data']['content'] as List<dynamic>;
  return content.cast<Map<String, dynamic>>();
});

const _typeLabels = {
  'GROUP_WALK': 'Promenade collective',
  'BEAUTY_CONTEST': 'Concours de beauté',
  'HEALTH_DAY': 'Journée santé',
  'ADOPTION': 'Adoption',
  'TRAINING_WORKSHOP': 'Atelier / dressage',
};

class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Événements')),
      body: AsyncView(
        value: eventsAsync,
        onRetry: () => ref.invalidate(eventsProvider),
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('Aucun événement à venir'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (_, i) {
              final e = events[i];
              final type = e['type'] as String? ?? '';
              final full = e['full'] as bool? ?? false;
              return Card(
                child: ListTile(
                  title: Text(e['title'] as String? ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_typeLabels[type] ?? type),
                      if (e['location'] != null) Text('📍 ${e['location']}'),
                      Text('${e['registeredCount'] ?? 0}/${e['capacity'] ?? 0} participants'),
                    ],
                  ),
                  trailing: FilledButton(
                    onPressed: full
                        ? null
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Inscription (à implémenter)')),
                            ),
                    child: Text(full ? 'Complet' : "S'inscrire"),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
