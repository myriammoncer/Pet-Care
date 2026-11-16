import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pet_event.dart';
import 'event_ui.dart';
import 'events_colors.dart';
import 'events_controller.dart';

/// Formulaire admin : création ([event] == null) ou modification d'un événement.
class EventFormPage extends ConsumerStatefulWidget {
  const EventFormPage({super.key, this.event});
  final PetEvent? event;

  @override
  ConsumerState<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends ConsumerState<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _capacity;

  late String _type;
  late DateTime _startAt;
  DateTime? _endAt;
  String? _dateError;
  bool _saving = false;

  bool get _isEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _capacity = TextEditingController(text: e?.capacity.toString() ?? '20');
    _type = e?.type ?? 'GROUP_WALK';
    if (e != null) {
      _startAt = e.startAt.toLocal();
      _endAt = e.endAt?.toLocal();
    } else {
      // Par défaut : dans 7 jours à 10h, durée 2h.
      final d = DateTime.now().add(const Duration(days: 7));
      _startAt = DateTime(d.year, d.month, d.day, 10);
      _endAt = _startAt.add(const Duration(hours: 2));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _isEdit ? DateTime(now.year - 1) : DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStart() async {
    final picked = await _pickDateTime(_startAt);
    if (picked == null) return;
    setState(() {
      // On conserve la durée si une fin était définie.
      final duration = _endAt?.difference(_startAt);
      _startAt = picked;
      if (duration != null && !duration.isNegative) _endAt = picked.add(duration);
      _dateError = null;
    });
  }

  Future<void> _pickEnd() async {
    final picked = await _pickDateTime(_endAt ?? _startAt.add(const Duration(hours: 2)));
    if (picked == null) return;
    setState(() {
      _endAt = picked;
      _dateError = null;
    });
  }

  String? _validateDates() {
    if (!_isEdit && !_startAt.isAfter(DateTime.now())) {
      return 'La date de début doit être dans le futur';
    }
    if (_endAt != null && !_endAt!.isAfter(_startAt)) {
      return 'La fin doit être après le début';
    }
    return null;
  }

  Future<void> _save() async {
    final dateError = _validateDates();
    setState(() => _dateError = dateError);
    if (!_formKey.currentState!.validate() || dateError != null) return;

    setState(() => _saving = true);
    final description = _description.text.trim();
    final body = <String, dynamic>{
      'title': _title.text.trim(),
      'description': description.isEmpty ? null : description,
      'type': _type,
      'startAt': _startAt.toUtc().toIso8601String(),
      'endAt': _endAt?.toUtc().toIso8601String(),
      'location': _location.text.trim(),
      'capacity': int.parse(_capacity.text.trim()),
    };
    try {
      final actions = ref.read(eventsActionsProvider);
      if (_isEdit) {
        await actions.update(widget.event!.id, body);
      } else {
        await actions.create(body);
      }
      if (!mounted) return;
      showEventSnack(context, _isEdit ? 'Événement mis à jour' : 'Événement créé');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showEventSnack(context, errorText(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registered = widget.event?.registeredCount ?? 0;
    return Scaffold(
      backgroundColor: EventsColors.background,
      appBar: AppBar(
        backgroundColor: EventsColors.background,
        foregroundColor: EventsColors.textStrong,
        elevation: 0,
        title: Text(_isEdit ? "Modifier l'événement" : 'Nouvel événement'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(EventsColors.gap),
          children: [
            TextFormField(
              controller: _title,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Titre'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre obligatoire' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                for (final entry in eventTypeLabels.entries)
                  DropdownMenuItem(
                    value: entry.key,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(eventTypeIcon(entry.key), size: 18, color: eventTypeColor(entry.key)),
                        const SizedBox(width: 8),
                        Text(entry.value),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _location,
              maxLength: 200,
              decoration: const InputDecoration(labelText: 'Lieu', prefixIcon: Icon(Icons.place_outlined)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Lieu obligatoire' : null,
            ),
            const SizedBox(height: 8),
            _DateTile(
              label: 'Début',
              value: '${formatDay(_startAt)} · ${formatTime(_startAt)}',
              onTap: _pickStart,
            ),
            _DateTile(
              label: 'Fin (optionnel)',
              value: _endAt == null ? 'Non définie' : '${formatDay(_endAt!)} · ${formatTime(_endAt!)}',
              onTap: _pickEnd,
              onClear: _endAt == null ? null : () => setState(() => _endAt = null),
            ),
            if (_dateError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(_dateError!, style: const TextStyle(color: EventsColors.danger, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _capacity,
              decoration: InputDecoration(
                labelText: 'Nombre de places',
                prefixIcon: const Icon(Icons.groups_outlined),
                helperText: _isEdit ? '$registered inscrit(s) actuellement' : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Nombre de places invalide';
                if (n < registered) return 'Au moins $registered (déjà inscrits)';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLength: 2000,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: EventsColors.primary,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _saving ? null : _save,
              child: Text(_saving
                  ? 'Enregistrement…'
                  : (_isEdit ? 'Enregistrer les modifications' : "Créer l'événement")),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.value, required this.onTap, this.onClear});
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event, color: EventsColors.primary),
      title: Text(label),
      subtitle: Text(value),
      onTap: onTap,
      trailing: onClear == null
          ? const Icon(Icons.edit_calendar_outlined)
          : IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
    );
  }
}
