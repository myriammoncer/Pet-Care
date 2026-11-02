import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../pets/presentation/pets_controller.dart';
import '../domain/agenda_item.dart';
import 'agenda_colors.dart';
import 'agenda_controller.dart';

const _types = {
  'VACCINATION': 'Vaccination',
  'DEWORMING': 'Vermifuge',
  'MEDICATION': 'Médicament',
  'VET_APPOINTMENT': 'Rendez-vous véto',
  'GROOMING': 'Toilettage',
};

const _recurrences = {
  'EVERY_WEEK': 'Chaque semaine',
  'EVERY_MONTH': 'Chaque mois',
  'EVERY_3_MONTHS': 'Tous les 3 mois',
  'EVERY_6_MONTHS': 'Tous les 6 mois',
  'EVERY_YEAR': 'Chaque année',
};

/// Formulaire de création (item == null) ou d'édition (item != null).
class AgendaFormPage extends ConsumerStatefulWidget {
  const AgendaFormPage({super.key, this.item});
  final AgendaItem? item;

  @override
  ConsumerState<AgendaFormPage> createState() => _AgendaFormPageState();
}

class _AgendaFormPageState extends ConsumerState<AgendaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _vetName;
  late final TextEditingController _location;
  late final TextEditingController _duration;

  String? _petId;
  String _type = 'VACCINATION';
  String? _recurrence;
  bool _urgent = false;
  late DateTime _scheduledAt;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _title = TextEditingController(text: it?.title ?? '');
    _notes = TextEditingController(text: it?.notes ?? '');
    _vetName = TextEditingController(text: it?.vetName ?? '');
    _location = TextEditingController(text: it?.location ?? '');
    _duration = TextEditingController(text: it?.durationMinutes?.toString() ?? '');
    _petId = it?.petId;
    _type = it?.type ?? 'VACCINATION';
    _recurrence = it?.recurrence;
    _urgent = it?.urgent ?? false;
    _scheduledAt = it?.scheduledAt.toLocal() ?? DateTime.now();
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _vetName.dispose();
    _location.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _petId == null) return;
    setState(() => _saving = true);
    final body = <String, dynamic>{
      'petId': _petId,
      'type': _type,
      'title': _title.text.trim(),
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      'scheduledAt': _scheduledAt.toUtc().toIso8601String(),
      'recurrence': _recurrence,
      'urgent': _urgent,
      'vetName': _vetName.text.trim().isEmpty ? null : _vetName.text.trim(),
      'location': _location.text.trim().isEmpty ? null : _location.text.trim(),
      'durationMinutes':
      _duration.text.trim().isEmpty ? null : int.tryParse(_duration.text.trim()),
    };
    try {
      final notifier = ref.read(agendaListProvider.notifier);
      if (_isEdit) {
        await notifier.updateItem(widget.item!.id, body);
      } else {
        await notifier.create(body);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    try {
      await ref.read(agendaListProvider.notifier).delete(widget.item!.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsListProvider);
    final dateLabel = DateFormat('dd/MM/yyyy à HH:mm').format(_scheduledAt);

    return Scaffold(
      backgroundColor: AgendaColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AgendaColors.scaffoldBg,
        foregroundColor: AgendaColors.textDark,
        elevation: 0,
        title: Text(_isEdit ? 'Modifier le rappel' : 'Nouveau rappel'),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            petsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur chargement animaux : $e'),
              data: (pets) {
                if (pets.isEmpty) {
                  return const Text("Crée d'abord un animal dans l'onglet Animaux.");
                }
                return DropdownButtonFormField<String>(
                  initialValue: _petId,
                  decoration: const InputDecoration(labelText: 'Animal'),
                  items: pets
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _petId = v),
                  validator: (v) => v == null ? 'Choisis un animal' : null,
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: _types.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? 'VACCINATION'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Titre obligatoire' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date et heure'),
              subtitle: Text(dateLabel),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _recurrence,
              decoration: const InputDecoration(labelText: 'Récurrence (optionnel)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Aucune')),
                ..._recurrences.entries.map(
                      (e) => DropdownMenuItem<String?>(value: e.key, child: Text(e.value)),
                ),
              ],
              onChanged: (v) => setState(() => _recurrence = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes (optionnel)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _vetName,
              decoration: const InputDecoration(labelText: 'Vétérinaire (optionnel)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Lieu (optionnel)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _duration,
              decoration: const InputDecoration(labelText: 'Durée en minutes (optionnel)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Urgent'),
              value: _urgent,
              onChanged: (v) => setState(() => _urgent = v),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AgendaColors.primary),
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(_saving
                    ? 'Enregistrement…'
                    : (_isEdit ? 'Enregistrer' : 'Créer le rappel')),
              ),
            ),
          ],
        ),
      ),

    );
  }
}