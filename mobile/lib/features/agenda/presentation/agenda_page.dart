import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/widgets/async_view.dart';

/// Récupère les éléments d'agenda du propriétaire courant.
final agendaProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/agenda');
  final content = response.data['data']['content'] as List<dynamic>;
  return content.cast<Map<String, dynamic>>();
});

const _typeLabels = {
  'VACCINATION': 'Vaccination',
  'DEWORMING': 'Vermifuge',
  'MEDICATION': 'Médicament',
  'VET_APPOINTMENT': 'Rendez-vous véto',
  'GROOMING': 'Toilettage',
};

const _typeIcons = {
  'VACCINATION': Icons.vaccines,
  'DEWORMING': Icons.bug_report,
  'MEDICATION': Icons.medication,
  'VET_APPOINTMENT': Icons.local_hospital,
  'GROOMING': Icons.content_cut,
};

class AgendaPage extends ConsumerWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaAsync = ref.watch(agendaProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: AsyncView(
        value: agendaAsync,
        onRetry: () => ref.invalidate(agendaProvider),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aucun rappel planifié'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final item = items[i];
              final type = item['type'] as String? ?? '';
              return ListTile(
                leading: Icon(_typeIcons[type] ?? Icons.event),
                title: Text(item['title'] as String? ?? _typeLabels[type] ?? type),
                subtitle: Text(item['scheduledAt'] as String? ?? ''),
                trailing: Chip(label: Text(item['status'] as String? ?? '')),
              );
            },
          );
        },
      ),
    );
  }
}
