import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/providers.dart';
import '../../../core/widgets/async_view.dart';
import '../../auth/presentation/auth_controller.dart';

/// Récupère le dossier médical d'un animal.
final medicalRecordProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, petId) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/pets/$petId/medical-record');
  return response.data['data'] as Map<String, dynamic>;
});

class MedicalRecordPage extends ConsumerStatefulWidget {
  const MedicalRecordPage({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends ConsumerState<MedicalRecordPage> {
  bool _isMutating = false;

  @override
  Widget build(BuildContext context) {
    final recordAsync = ref.watch(medicalRecordProvider(widget.petId));
    final canEdit =
        ref.watch(authControllerProvider).state.user?.isVet ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pets/${widget.petId}'),
        ),
        title: const Text('Dossier médical'),
      ),
      body: AsyncView(
        value: recordAsync,
        onRetry: () => ref.invalidate(medicalRecordProvider(widget.petId)),
        data: (record) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(
              context,
              title: 'Consultations',
              icon: Icons.event_note,
              items: _items(record, 'consultations'),
              canEdit: canEdit,
              onAdd: () => _addItem('consultations'),
              onDelete: (id) => _deleteItem('consultations', id),
            ),
            _section(
              context,
              title: 'Vaccinations',
              icon: Icons.vaccines,
              items: _items(record, 'vaccinations'),
              canEdit: canEdit,
              onAdd: () => _addItem('vaccinations'),
              onDelete: (id) => _deleteItem('vaccinations', id),
            ),
            _section(
              context,
              title: 'Allergies',
              icon: Icons.warning_amber,
              items: _items(record, 'allergies'),
              canEdit: canEdit,
              onAdd: () => _addItem('allergies'),
              onDelete: (id) => _deleteItem('allergies', id),
            ),
            _section(
              context,
              title: 'Médicaments',
              icon: Icons.medication,
              items: _items(record, 'medications'),
              canEdit: canEdit,
              onAdd: () => _addItem('medications'),
              onDelete: (id) => _deleteItem('medications', id),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> record, String key) {
    final values = record[key] as List? ?? const [];
    return values
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required bool canEdit,
    required VoidCallback onAdd,
    required ValueChanged<String> onDelete,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (canEdit)
                  IconButton(
                    tooltip: 'Ajouter',
                    onPressed: _isMutating ? null : onAdd,
                    icon: const Icon(Icons.add),
                  ),
              ],
            ),
            const Divider(),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Aucune donnée'),
              )
            else
              ...items.map((item) {
                final id = item['id']?.toString();
                final details = _itemDetails(item);
                return ListTile(
                  dense: true,
                  title: Text(_itemTitle(item)),
                  subtitle: details == null ? null : Text(details),
                  trailing: canEdit && id != null
                      ? IconButton(
                          tooltip: 'Supprimer',
                          onPressed: _isMutating ? null : () => onDelete(id),
                          icon: const Icon(Icons.delete_outline),
                        )
                      : null,
                );
              }),
          ],
        ),
      ),
    );
  }

  String _itemTitle(Map<String, dynamic> item) {
    return (item['reason'] ??
            item['vaccineName'] ??
            item['substance'] ??
            item['name'] ??
            'Entrée médicale')
        .toString();
  }

  String? _itemDetails(Map<String, dynamic> item) {
    final details = <String>[];
    void add(String label, dynamic value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        details.add('$label : $value');
      }
    }

    add('Date', item['date']);
    add('Diagnostic', item['diagnosis']);
    add('Notes', item['notes']);
    add('Prochain rappel', item['nextDueDate']);
    add('Sévérité', _severityLabel(item['severity']?.toString()));
    add('Réaction', item['reaction']);
    add('Dosage', item['dosage']);
    add('Fréquence', item['frequency']);
    add('Début', item['startDate']);
    add('Fin', item['endDate']);
    return details.isEmpty ? null : details.join('\n');
  }

  String? _severityLabel(String? value) {
    switch (value) {
      case 'LOW':
        return 'Faible';
      case 'MEDIUM':
        return 'Modérée';
      case 'HIGH':
        return 'Élevée';
      default:
        return value;
    }
  }

  Future<void> _addItem(String section) async {
    final body = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _MedicalEntryDialog(section: section),
    );
    if (body == null || !mounted) return;

    setState(() => _isMutating = true);
    try {
      await ref.read(dioProvider).post(
            '/pets/${widget.petId}/medical-record/$section',
            data: body,
          );
      ref.invalidate(medicalRecordProvider(widget.petId));
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _deleteItem(String section, String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette entrée ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isMutating = true);
    try {
      await ref.read(dioProvider).delete(
            '/pets/${widget.petId}/medical-record/$section/$itemId',
          );
      ref.invalidate(medicalRecordProvider(widget.petId));
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  void _showError(Object error) {
    var message =
        "L'opération a échoué. Vérifiez votre connexion et réessayez.";
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final apiError = data['error'];
        if (apiError is Map && apiError['message'] is String) {
          message = apiError['message'] as String;
        } else if (data['message'] is String) {
          message = data['message'] as String;
        }
      }
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MedicalEntryDialog extends StatefulWidget {
  const _MedicalEntryDialog({required this.section});

  final String section;

  @override
  State<_MedicalEntryDialog> createState() => _MedicalEntryDialogState();
}

class _MedicalEntryDialogState extends State<_MedicalEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _reactionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  DateTime _date = DateTime.now();
  DateTime? _optionalDate;
  String _severity = 'LOW';

  @override
  void dispose() {
    _nameController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _reactionController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.section) {
      'consultations' => 'Ajouter une consultation',
      'vaccinations' => 'Ajouter une vaccination',
      'allergies' => 'Ajouter une allergie',
      _ => 'Ajouter un médicament',
    };

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _fields(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  List<Widget> _fields() {
    switch (widget.section) {
      case 'consultations':
        return [
          _dateField('Date', _date, (date) => setState(() => _date = date)),
          _textField(_nameController, 'Motif', required: true),
          _textField(_diagnosisController, 'Diagnostic'),
          _textField(_notesController, 'Notes', maxLines: 3),
        ];
      case 'vaccinations':
        return [
          _textField(_nameController, 'Nom du vaccin', required: true),
          _dateField('Date', _date, (date) => setState(() => _date = date)),
          _dateField(
            'Prochain rappel (facultatif)',
            _optionalDate,
            (date) => setState(() => _optionalDate = date),
            clearable: true,
          ),
        ];
      case 'allergies':
        return [
          _textField(_nameController, 'Substance', required: true),
          DropdownButtonFormField<String>(
            initialValue: _severity,
            decoration: const InputDecoration(labelText: 'Sévérité'),
            items: const [
              DropdownMenuItem(value: 'LOW', child: Text('Faible')),
              DropdownMenuItem(value: 'MEDIUM', child: Text('Modérée')),
              DropdownMenuItem(value: 'HIGH', child: Text('Élevée')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _severity = value);
            },
          ),
          _textField(_reactionController, 'Réaction'),
          _textField(_notesController, 'Notes', maxLines: 3),
        ];
      default:
        return [
          _textField(_nameController, 'Nom du médicament', required: true),
          _textField(_dosageController, 'Dosage', required: true),
          _textField(_frequencyController, 'Fréquence'),
          _dateField(
              'Date de début', _date, (date) => setState(() => _date = date)),
          _dateField(
            'Date de fin (facultatif)',
            _optionalDate,
            (date) => setState(() => _optionalDate = date),
            clearable: true,
          ),
        ];
    }
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) =>
              value == null || value.trim().isEmpty ? 'Champ obligatoire' : null
          : null,
    );
  }

  Widget _dateField(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onChanged, {
    bool clearable = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(label),
            subtitle: Text(value == null
                ? 'Non renseignée'
                : DateFormat('dd/MM/yyyy').format(value)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2200),
              );
              if (selected != null) onChanged(selected);
            },
          ),
        ),
        if (clearable && value != null)
          IconButton(
            tooltip: 'Effacer la date',
            onPressed: () => setState(() => _optionalDate = null),
            icon: const Icon(Icons.clear),
          ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final body = switch (widget.section) {
      'consultations' => <String, dynamic>{
          'date': DateTime.utc(_date.year, _date.month, _date.day)
              .toIso8601String(),
          'reason': _nameController.text.trim(),
          'diagnosis': _optional(_diagnosisController),
          'notes': _optional(_notesController),
        },
      'vaccinations' => <String, dynamic>{
          'vaccineName': _nameController.text.trim(),
          'date': _formatDate(_date),
          'nextDueDate':
              _optionalDate == null ? null : _formatDate(_optionalDate!),
        },
      'allergies' => <String, dynamic>{
          'substance': _nameController.text.trim(),
          'severity': _severity,
          'reaction': _optional(_reactionController),
          'notes': _optional(_notesController),
        },
      _ => <String, dynamic>{
          'name': _nameController.text.trim(),
          'dosage': _dosageController.text.trim(),
          'frequency': _optional(_frequencyController),
          'startDate': _formatDate(_date),
          'endDate': _optionalDate == null ? null : _formatDate(_optionalDate!),
        },
    };
    Navigator.pop(context, body);
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
