import 'package:flutter/material.dart';

/// Palette locale de la feature Agenda, tirée de la maquette validée.
/// Locale à la feature : ne modifie pas le thème commun (socle).
class AgendaColors {
  AgendaColors._();

  // Verts
  static const Color primary = Color(0xFF1C7C54);      // vert principal (jour sélectionné, boutons)
  static const Color primaryDark = Color(0xFF0E5C3A);  // vert foncé (bouton "Prendre un rdv")
  static const Color accent = Color(0xFF2EA66A);       // vert moyen ("Valider", badge "Actif")
  static const Color greenSoftBg = Color(0xFFDFF3E7);  // fond vert clair (pills, tags vaccination)

  // Fonds & bordures
  static const Color scaffoldBg = Color(0xFFF4F6F5);   // fond général de l'écran
  static const Color card = Color(0xFFFFFFFF);         // fond des cartes
  static const Color border = Color(0xFFE6EAE8);       // bordures légères

  // Textes
  static const Color textDark = Color(0xFF1E2A32);     // titres
  static const Color textMuted = Color(0xFF7B8A93);    // sous-textes gris

  // Accents par type / statut
  static const Color danger = Color(0xFFE4572E);       // médicament / urgent (rouge-corail)
  static const Color dangerBg = Color(0xFFFCE6DF);     // fond du badge danger
  static const Color info = Color(0xFF3B82C4);         // consultation (bleu)
  static const Color infoBg = Color(0xFFE2EEF8);       // fond du badge info
}