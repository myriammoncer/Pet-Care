import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/widgets/async_view.dart';

/// Récupère le dossier médical d'un animal.
final medicalRecordProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, petId) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/pets/$petId/medical-record');
  return response.data['data'] as Map<String, dynamic>;
});

class MedicalRecordPage extends ConsumerWidget {
  const MedicalRecordPage({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(medicalRecordProvider(petId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/$petId'),
        ),
        title: const Text('Dossier médical'),
      ),
      body: AsyncView(
        value: recordAsync,
        onRetry: () => ref.invalidate(medicalRecordProvider(petId)),
        data: (record) {
          final consultations = (record['consultations'] as List?) ?? [];
          final vaccinations = (record['vaccinations'] as List?) ?? [];
          final allergies = (record['allergies'] as List?) ?? [];
          final medications = (record['medications'] as List?) ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section(context, 'Consultations', Icons.event_note, consultations,
                  (c) => '${c['reason'] ?? ''} — ${c['diagnosis'] ?? ''}'),
              _section(context, 'Vaccinations', Icons.vaccines, vaccinations,
                  (v) => '${v['vaccineName'] ?? ''} (${v['date'] ?? ''})'),
              _section(context, 'Allergies', Icons.warning_amber, allergies,
                  (a) => '${a['substance'] ?? ''} — ${a['severity'] ?? ''}'),
              _section(context, 'Médicaments', Icons.medication, medications,
                  (m) => '${m['name'] ?? ''} — ${m['dosage'] ?? ''}'),
            ],
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon, List<dynamic> items,
      String Function(dynamic) label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleMedium)]),
            const Divider(),
            if (items.isEmpty)
              const Padding(padding: EdgeInsets.all(8), child: Text('Aucune donnée'))
            else
              ...items.map((e) => ListTile(dense: true, title: Text(label(e)))),
          ],
        ),
      ),
    );
  }
}
