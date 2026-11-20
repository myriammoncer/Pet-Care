import 'package:flutter/material.dart';

import '../data/event_failure.dart';
import '../domain/pet_event.dart';
import 'events_colors.dart';

/// Libellés, icônes, couleurs, images et formats partagés par les écrans Événements.

const eventTypeLabels = {
  'GROUP_WALK': 'Promenade collective',
  'BEAUTY_CONTEST': 'Concours de beauté',
  'HEALTH_DAY': 'Journée santé & dépistage',
  'ADOPTION': 'Adoption',
  'TRAINING_WORKSHOP': 'Atelier & Dressage',
};

/// Libellés des puces de filtre (maquette).
const eventTypeShortLabels = {
  'GROUP_WALK': 'Promenades collectives',
  'BEAUTY_CONTEST': 'Concours de beauté',
  'HEALTH_DAY': 'Journées santé & dépistage',
  'ADOPTION': 'Adoption',
  'TRAINING_WORKSHOP': 'Ateliers & Dressage',
};

const _typeIcons = {
  'GROUP_WALK': Icons.pets,
  'BEAUTY_CONTEST': Icons.workspace_premium_outlined,
  'HEALTH_DAY': Icons.medical_services_outlined,
  'ADOPTION': Icons.favorite_border,
  'TRAINING_WORKSHOP': Icons.school_outlined,
};

/// Couleurs (fond, texte) de la pastille de type, reprises de la maquette.
const _typePill = {
  'GROUP_WALK': (Color(0xFFA1F4C5), Color(0xFF1B724D)),
  'BEAUTY_CONTEST': (Color(0xFFD8E3FB), Color(0xFF111C2D)),
  'HEALTH_DAY': (Color(0xFFA4F3CA), Color(0xFF002113)),
  'ADOPTION': (Color(0xFFDEE8FF), Color(0xFF3F4943)),
  'TRAINING_WORKSHOP': (Color(0xFFA1F4C5), Color(0xFF1B724D)),
};

/// Illustration par type (photos de la maquette, dans assets/images/).
const _typeImages = {
  'GROUP_WALK': 'assets/images/event_walk.jpg',
  'BEAUTY_CONTEST': 'assets/images/event_contest.jpg',
  'HEALTH_DAY': 'assets/images/event_health.jpg',
  'ADOPTION': 'assets/images/event_adoption.jpg',
  'TRAINING_WORKSHOP': 'assets/images/event_workshop.jpg',
};

IconData eventTypeIcon(String type) => _typeIcons[type] ?? Icons.celebration_outlined;

/// Couleur d'accent du type (texte de sa pastille).
Color eventTypeColor(String type) => (_typePill[type] ?? (EventsColors.mint, EventsColors.onMint)).$2;

Color eventTypeBackground(String type) => (_typePill[type] ?? (EventsColors.mint, EventsColors.onMint)).$1;

String eventTypeLabel(String type) => eventTypeLabels[type] ?? type;

String eventTypeImage(String type) => _typeImages[type] ?? 'assets/images/event_walk.jpg';

const _jours = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
const _joursLongs = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
const _mois = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];
const _moisLongs = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];

String _two(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime d) {
  final l = d.toLocal();
  return '${_two(l.hour)}:${_two(l.minute)}';
}

/// « sam. 21 nov. 2026 » (sans dépendre de l'initialisation de la locale intl).
String formatDay(DateTime d) {
  final l = d.toLocal();
  return '${_jours[l.weekday - 1]} ${l.day} ${_mois[l.month - 1]} ${l.year}';
}

/// « sam. 21 nov. 2026 · 09:00 – 11:00 » (écran de détail).
String formatEventWhen(PetEvent e) {
  final start = '${formatDay(e.startAt)} · ${formatTime(e.startAt)}';
  final end = e.endAt;
  if (end == null) return start;
  final s = e.startAt.toLocal();
  final en = end.toLocal();
  final sameDay = s.year == en.year && s.month == en.month && s.day == en.day;
  return sameDay ? '$start – ${formatTime(end)}' : '$start → ${formatDay(end)} · ${formatTime(end)}';
}

String _hour(DateTime l, {bool compact = false}) {
  if (compact && l.minute == 0) return '${l.hour}h';
  return '${l.hour}h${_two(l.minute)}';
}

/// Format de la maquette : « Samedi 8 Juin • 14h-18h » ou « Dimanche 26 Mai • 10h00 ».
String formatEventShort(PetEvent e) {
  final s = e.startAt.toLocal();
  final day = '${_joursLongs[s.weekday - 1]} ${s.day} ${_moisLongs[s.month - 1]}';
  final end = e.endAt?.toLocal();
  if (end == null) return '$day • ${_hour(s)}';
  final sameDay = s.year == end.year && s.month == end.month && s.day == end.day;
  if (!sameDay) return '$day • ${_hour(s)}';
  return '$day • ${_hour(s, compact: true)}-${_hour(end, compact: true)}';
}

/// Message lisible pour une erreur (EventFailure du data layer ou autre).
String errorText(Object error) => error is EventFailure ? error.message : '$error';

void showEventSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? EventsColors.danger : EventsColors.textStrong,
    ));
}

/// Pastille du type d'événement (maquette : fond pastel, texte gras 10 px).
class EventTypeBadge extends StatelessWidget {
  const EventTypeBadge(this.type, {super.key});
  final String type;

  @override
  Widget build(BuildContext context) {
    return EventPill(
      icon: eventTypeIcon(type),
      label: eventTypeLabel(type),
      background: eventTypeBackground(type),
      foreground: eventTypeColor(type),
    );
  }
}

/// Petite pastille arrondie icône + texte.
class EventPill extends StatelessWidget {
  const EventPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.uppercase = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 10,
                height: 1.4,
                fontWeight: FontWeight.w700,
                letterSpacing: uppercase ? 0.25 : 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre de remplissage « 12 / 25 places » (écran de détail).
class CapacityBar extends StatelessWidget {
  const CapacityBar(this.event, {super.key, this.dense = false});
  final PetEvent event;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = event.full
        ? EventsColors.danger
        : event.fillRatio >= 0.8
            ? const Color(0xFFC98A12)
            : EventsColors.primary;
    final label = event.full
        ? 'Complet · ${event.registeredCount}/${event.capacity}'
        : '${event.remainingSpots} place${event.remainingSpots > 1 ? 's' : ''} restante'
            '${event.remainingSpots > 1 ? 's' : ''} · ${event.registeredCount}/${event.capacity}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: event.fillRatio,
            minHeight: dense ? 5 : 8,
            backgroundColor: EventsColors.chip,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: dense ? 12 : 13, color: EventsColors.textMuted)),
      ],
    );
  }
}
