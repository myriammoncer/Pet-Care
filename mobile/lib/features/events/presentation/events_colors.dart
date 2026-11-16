import 'package:flutter/material.dart';

/// Palette du module Événements, reprise de la maquette Figma
/// « Événements & Communauté ». Propre au module (comme `AgendaColors`).
class EventsColors {
  EventsColors._();

  static const Color background = Color(0xFFF9F9FF);
  static const Color card = Colors.white;

  /// Vert principal (boutons pleins, puce sélectionnée, dates).
  static const Color primary = Color(0xFF096444);

  /// Vert du bouton flottant « Proposer un événement ».
  static const Color primarySoft = Color(0xFF2E7D5B);
  static const Color primaryDark = Color(0xFF1B724D);

  /// Fond des puces et boutons secondaires.
  static const Color chip = Color(0xFFE7EEFF);
  static const Color chipAlt = Color(0xFFF0F3FF);

  static const Color mint = Color(0xFFA1F4C5);
  static const Color onMint = Color(0xFF1B724D);

  static const Color textStrong = Color(0xFF111C2D);
  static const Color textMuted = Color(0xFF3F4943);

  /// Alerte « places restantes » / complet.
  static const Color alert = Color(0xFFFFDAD2);
  static const Color onAlert = Color(0xFF3D0600);
  static const Color danger = Color(0xFFB84F37);

  static const Color border = Color(0xFFE2E8F5);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const double radius = 12;
  static const double gap = 16;

  static const BoxDecoration cardDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    boxShadow: cardShadow,
  );
}
