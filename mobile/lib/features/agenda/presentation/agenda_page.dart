import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/widgets/async_view.dart';
import '../../pets/domain/pet.dart';
import '../../pets/presentation/pets_controller.dart';
import '../domain/agenda_item.dart';
import 'agenda_colors.dart';
import 'agenda_controller.dart';
import 'agenda_form_page.dart';

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

const _moisFr = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
];

String _frDate(DateTime d) => '${d.day} ${_moisFr[d.month - 1]}';

/// Libellés français des espèces (codes envoyés par le backend).
const _speciesFr = {
  'DOG': 'Chien',
  'CAT': 'Chat',
  'BIRD': 'Oiseau',
  'RABBIT': 'Lapin',
  'RODENT': 'Rongeur',
  'REPTILE': 'Reptile',
  'OTHER': 'Autre',
};
/// Couleur d'accent selon le type de soin (repris de la maquette).
Color _typeColor(String type) {
  switch (type) {
    case 'MEDICATION':
      return AgendaColors.danger;
    case 'VET_APPOINTMENT':
      return AgendaColors.info;
    default:
      return AgendaColors.accent;
  }
}

/// Les 3 vues du haut de l'écran.
enum _View { mois, semaine, liste }

class AgendaPage extends ConsumerStatefulWidget {
  const AgendaPage({super.key});

  @override
  ConsumerState<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends ConsumerState<AgendaPage> {
  _View _view = _View.semaine;
  String? _typeFilter; // null = Tous
  String? _petFilter; // null = tous les animaux
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late bool _calendarSync = ref.read(agendaNotificationsProvider).enabled;
  bool _frLocaleReady = false;

  @override
  void initState() {
    super.initState();
    // Charge les noms de mois / jours en français pour le calendrier.
    initializeDateFormatting('fr_FR').then((_) {
      if (mounted) setState(() => _frLocaleReady = true);
    });
  }  /// Les 7 jours (lundi → dimanche) de la semaine du jour sélectionné.
  List<DateTime> get _weekDays {
    final monday =
        _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    return List.generate(
        7, (i) => DateTime(monday.year, monday.month, monday.day + i));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  /// Vrai si le rappel correspond à l'animal et au type sélectionnés.
  bool _matchesFilters(AgendaItem it) {
    if (_petFilter != null && it.petId != _petFilter) return false;
    if (_typeFilter != null && it.type != _typeFilter) return false;
    return true;
  }

  /// Filtre la liste selon l'animal, le type et la vue (période) sélectionnés.
  List<AgendaItem> _filter(List<AgendaItem> items) {
    final result = items.where((it) {
      if (!_matchesFilters(it)) return false;
      final d = it.scheduledAt.toLocal();
      switch (_view) {
        case _View.liste:
          return true;
        case _View.semaine:
          final days = _weekDays;
          final start =
              DateTime(days.first.year, days.first.month, days.first.day);
          final end =
              DateTime(days.last.year, days.last.month, days.last.day + 1);
          return !d.isBefore(start) && d.isBefore(end);
        case _View.mois:
          return _sameDay(d, _selectedDay);
      }
    }).toList();
    result.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result;
  }

  Future<void> _markDone(AgendaItem it) async {
    try {
      await ref.read(agendaListProvider.notifier).updateStatus(it.id, 'DONE');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  /// Annule un rappel après confirmation (statut CANCELLED).
  Future<void> _cancel(AgendaItem it) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler ce rappel ?'),
        content: Text('« ${it.title} » sera marqué comme annulé.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Non')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AgendaColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref
          .read(agendaListProvider.notifier)
          .updateStatus(it.id, 'CANCELLED');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final agendaAsync = ref.watch(agendaListProvider);
    final petsAsync = ref.watch(petsListProvider);
    final pets = petsAsync.valueOrNull ?? const <Pet>[];
    final petNames = {for (final p in pets) p.id: p.name};
    final selectedPet = pets.where((p) => p.id == _petFilter).firstOrNull;    return Scaffold(
      backgroundColor: AgendaColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AgendaColors.scaffoldBg,
        elevation: 0,
        foregroundColor: AgendaColors.textDark,
        title: const Text('Agenda & Soins',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AgendaColors.primary,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AgendaFormPage()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: AsyncView<List<AgendaItem>>(
        value: agendaAsync,
        onRetry: () => ref.invalidate(agendaListProvider),
        data: (items) {
          final filtered = _filter(items);
          final now = DateTime.now();
          final today = <AgendaItem>[];
          final upcoming = <AgendaItem>[];
          final past = <AgendaItem>[];
          for (final it in filtered) {
            final d = it.scheduledAt.toLocal();
            if (_sameDay(d, now)) {
              today.add(it);
            } else if (d.isAfter(now)) {
              upcoming.add(it);
            } else {
              past.add(it);
            }
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(agendaListProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                if (pets.isNotEmpty) ...[
                  _petChips(pets),
                  const SizedBox(height: 12),
                ],
                if (selectedPet != null) ...[
                  _petHeader(selectedPet),
                  const SizedBox(height: 14),
                ],
                _viewTabs(),
                const SizedBox(height: 14),
                if (_view == _View.semaine) ...[
                  _weekStrip(),
                  const SizedBox(height: 14),
                ] else if (_view == _View.mois) ...[
                  _monthCalendar(items),
                  const SizedBox(height: 14),
                ],
                _typeChips(),
                const SizedBox(height: 18),
                ..._buildSections(today, upcoming, past, petNames),                const SizedBox(height: 8),
                _syncToggleCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construit les sections Aujourd'hui / À venir / Passés (non vides).
  List<Widget> _buildSections(List<AgendaItem> today, List<AgendaItem> upcoming,
      List<AgendaItem> past, Map<String, String> petNames) {
    final widgets = <Widget>[];

    void addGroup(String title, List<AgendaItem> group) {
      if (group.isEmpty) return;
      widgets.add(_sectionHeader(title, group.length));
      widgets.add(const SizedBox(height: 10));
      for (final it in group) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AgendaCard(
            item: it,
            petName: petNames[it.petId],
            onValidate: () => _markDone(it),
            onCancel: () => _cancel(it),
          ),        ));
      }
      widgets.add(const SizedBox(height: 8));
    }

    addGroup("Aujourd'hui, ${_frDate(DateTime.now())}", today);
    addGroup('À venir', upcoming);
    addGroup('Passés', past);

    if (widgets.isEmpty) {
      widgets.add(const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: Text('Aucun rappel sur cette période')),
      ));
    }
    return widgets;
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AgendaColors.textDark)),
        Text('$count soin${count > 1 ? 's' : ''}',
            style: const TextStyle(color: AgendaColors.textMuted, fontSize: 13)),
      ],
    );
  }

  /// Onglets Mois / Semaine / Liste (segmented control).
  Widget _viewTabs() {
    Widget tab(String label, _View v) {
      final selected = _view == v;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _view = v),
          child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AgendaColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : AgendaColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgendaColors.border),
      ),
      child: Row(
        children: [
          tab('Mois', _View.mois),
          tab('Semaine', _View.semaine),
          tab('Liste', _View.liste),
        ],
      ),
    );
  }

  /// Vrai calendrier mensuel (vue Mois).
  Widget _monthCalendar(List<AgendaItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgendaColors.border),
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar<AgendaItem>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        currentDay: DateTime.now(),
        locale: _frLocaleReady ? 'fr_FR' : null,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.horizontalSwipe,
        selectedDayPredicate: (day) => _sameDay(day, _selectedDay),
        eventLoader: (day) => items
            .where((it) =>
        _matchesFilters(it) && _sameDay(it.scheduledAt.toLocal(), day))            .toList(),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) => _focusedDay = focused,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold, color: AgendaColors.textDark),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
              color: AgendaColors.primary, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(
              color: AgendaColors.primary.withValues(alpha: 0.35),
              shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(
              color: AgendaColors.accent, shape: BoxShape.circle),
          markersMaxCount: 3,
        ),
      ),
    );
  }

  /// Bande des 7 jours de la semaine.
  Widget _weekStrip() {
    const names = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = _weekDays[i];
        final selected = _sameDay(day, _selectedDay);
        return GestureDetector(
          onTap: () => setState(() => _selectedDay = day),
          child: Column(
            children: [
              Text(names[i],
                  style: const TextStyle(
                      fontSize: 11, color: AgendaColors.textMuted)),
              const SizedBox(height: 6),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AgendaColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: selected ? Colors.white : AgendaColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Puces de filtre par type.
  Widget _typeChips() {
    Widget chip(String label, String? type) {
      final selected = _typeFilter == type;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => setState(() => _typeFilter = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AgendaColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selected ? AgendaColors.primary : AgendaColors.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AgendaColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Tous', null),
          chip('Vaccination', 'VACCINATION'),
          chip('Médicaments', 'MEDICATION'),
          chip('Vermifuge', 'DEWORMING'),
          chip('Rendez-vous', 'VET_APPOINTMENT'),
          chip('Toilettage', 'GROOMING'),
        ],
      ),
    );
  }

  /// Carte « Synchronisation Calendrier » (bas de l'écran).
  Widget _syncToggleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgendaColors.border),
      ),
      child: SwitchListTile(
        value: _calendarSync,
        onChanged: (v) {
          setState(() => _calendarSync = v);
          ref.read(agendaListProvider.notifier).setRemindersEnabled(v);
        },
        secondary: const Icon(Icons.sync, color: AgendaColors.primary),
        title: const Text('Synchronisation Calendrier',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AgendaColors.textDark)),
        subtitle: const Text(
          'Rappel avant chaque soin pour ne rien oublier.',
          style: TextStyle(color: AgendaColors.textMuted, fontSize: 12),
        ),
      ),
    );
  }
  /// Sélecteur d'animal : « Tous » + une puce avec photo par animal.
  Widget _petChips(List<Pet> pets) {
    Widget chip({required String label, String? petId, Widget? avatar}) {
      final selected = _petFilter == petId;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => setState(() => _petFilter = petId),
          child: Container(
            padding: avatar != null
                ? const EdgeInsets.fromLTRB(4, 4, 14, 4)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AgendaColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: selected ? AgendaColors.primary : AgendaColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avatar != null) ...[
                  ClipOval(child: avatar),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AgendaColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(label: 'Tous les animaux'),
          for (final p in pets)
            chip(label: p.name, petId: p.id, avatar: _petImage(p, 28)),
        ],
      ),
    );
  }

  /// En-tête présentant l'animal avec sa photo (maquette « Milo »).
  Widget _petHeader(Pet pet) {
    final subtitle = [_speciesFr[pet.species] ?? pet.species, pet.breed]
        .where((e) => e != null && e.isNotEmpty)
        .join(' · ');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgendaColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _petImage(pet, 54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AgendaColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AgendaColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AgendaColors.greenSoftBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Actif',
                style: TextStyle(
                    color: AgendaColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// Photo de l'animal : photoUrl en ligne → asset local → icône (sans erreur).
  Widget _petImage(Pet pet, double size) {
    if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
      return Image.network(
        pet.photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _dogFallback(size),
      );
    }
    return _dogFallback(size);
  }

  Widget _dogFallback(double size) {
    return Image.asset(
      'assets/images/dog.jpg',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: AgendaColors.greenSoftBg,
        child: const Icon(Icons.pets, color: AgendaColors.primary),
      ),
    );
  }
}

/// Carte d'un élément d'agenda (cliquable pour éditer).
class _AgendaCard extends StatelessWidget {
  const _AgendaCard(
      {required this.item, this.petName, this.onValidate, this.onCancel});
  final AgendaItem item;
  final String? petName;
  final VoidCallback? onValidate;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(item.type);
    final time = DateFormat('HH:mm').format(item.scheduledAt.toLocal());
    final subtitle = [
      if (petName != null) 'Pour $petName',
      item.vetName,
      item.location,
      item.notes,
    ].where((e) => e != null && e.isNotEmpty).join(' · ');
    final isScheduled = item.status == 'SCHEDULED';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AgendaFormPage(item: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AgendaColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AgendaColors.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(_typeIcons[item.type] ?? Icons.event, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(time,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AgendaColors.textDark)),
                          const SizedBox(width: 8),
                          _Badge(
                              label: _typeLabels[item.type] ?? item.type,
                              color: color),
                          if (item.urgent) ...[
                            const SizedBox(width: 6),
                            const _Badge(
                                label: 'Urgent', color: AgendaColors.danger),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AgendaColors.textDark)),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: const TextStyle(
                                color: AgendaColors.textMuted, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
                _StatusChip(status: item.status),
              ],
            ),
            if (isScheduled && onValidate != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AgendaColors.danger,
                        side: const BorderSide(color: AgendaColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: onCancel,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AgendaColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: onValidate,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Valider'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Petite pastille colorée (type, urgence…).
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

/// Pastille d'état (Prévu / Fait / Manqué / Annulé).
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    const labels = {
      'SCHEDULED': 'Prévu',
      'DONE': 'Fait',
      'MISSED': 'Manqué',
      'CANCELLED': 'Annulé',
    };
    final color = switch (status) {
      'DONE' => AgendaColors.accent,
      'MISSED' => AgendaColors.danger,
      'CANCELLED' => AgendaColors.textMuted,
      _ => AgendaColors.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(labels[status] ?? status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
