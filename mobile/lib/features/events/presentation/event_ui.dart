import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../data/event_failure.dart';
import '../domain/pet_event.dart';

/// Libellés, icônes, couleurs et formats partagés par les écrans Événements.

const eventTypeLabels = {
  'GROUP_WALK': 'Promenade collective',
  'BEAUTY_CONTEST': 'Concours de beauté',
  'HEALTH_DAY': 'Journée santé',
  'ADOPTION': 'Adoption',
  'TRAINING_WORKSHOP': 'Atelier / dressage',
};

/// Libellés courts pour les puces de filtre.
const eventTypeShortLabels = {
  'GROUP_WALK': 'Promenades',
  'BEAUTY_CONTEST': 'Concours',
  'HEALTH_DAY': 'Santé',
  'ADOPTION': 'Adoption',
  'TRAINING_WORKSHOP': 'Ateliers',
};

const _typeIcons = {
  'GROUP_WALK': Icons.directions_walk,
  'BEAUTY_CONTEST': Icons.emoji_events,
  'HEALTH_DAY': Icons.health_and_safety,
  'ADOPTION': Icons.volunteer_activism,
  'TRAINING_WORKSHOP': Icons.school,
};

const _typeColors = {
  'GROUP_WALK': AppTokens.primary,
  'BEAUTY_CONTEST': Color(0xFFC98A12),
  'HEALTH_DAY': AppTokens.onInfo,
  'ADOPTION': AppTokens.accent,
  'TRAINING_WORKSHOP': Color(0xFF7B4FBF),
};

IconData eventTypeIcon(String type) => _typeIcons[type] ?? Icons.celebration;

Color eventTypeColor(String type) => _typeColors[type] ?? AppTokens.primary;

String eventTypeLabel(String type) => eventTypeLabels[type] ?? type;

const _jours = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
const _mois = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
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

/// « sam. 21 nov. 2026 · 09:00 – 11:00 ».
String formatEventWhen(PetEvent e) {
  final start = '${formatDay(e.startAt)} · ${formatTime(e.startAt)}';
  final end = e.endAt;
  if (end == null) return start;
  final s = e.startAt.toLocal();
  final en = end.toLocal();
  final sameDay = s.year == en.year && s.month == en.month && s.day == en.day;
  return sameDay ? '$start – ${formatTime(end)}' : '$start → ${formatDay(end)} · ${formatTime(end)}';
}

/// Message lisible pour une erreur (EventFailure du data layer ou autre).
String errorText(Object error) => error is EventFailure ? error.message : '$error';

void showEventSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppTokens.danger : null,
    ));
}

/// Pastille colorée du type d'événement.
class EventTypeBadge extends StatelessWidget {
  const EventTypeBadge(this.type, {super.key});
  final String type;

  @override
  Widget build(BuildContext context) {
    final color = eventTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(eventTypeIcon(type), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            eventTypeLabel(type),
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Barre de remplissage « 12 / 25 places ».
class CapacityBar extends StatelessWidget {
  const CapacityBar(this.event, {super.key, this.dense = false});
  final PetEvent event;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = event.full
        ? AppTokens.danger
        : event.fillRatio >= 0.8
            ? AppTokens.accent
            : AppTokens.primary;
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
            backgroundColor: AppTokens.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: dense ? 12 : 13, color: AppTokens.textMuted)),
      ],
    );
  }
}
