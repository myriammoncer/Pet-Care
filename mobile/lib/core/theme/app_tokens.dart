import 'package:flutter/material.dart';

/// Jetons de design (couleurs, rayons, espacements) extraits de la maquette Figma.
///
/// On NE modifie PAS `app_theme.dart` (fichier commun) : on ajoute ici des
/// constantes réutilisables par les écrans du module User, cohérentes avec la
/// charte « vert soin ».
class AppTokens {
  AppTokens._(); // classe utilitaire : pas d'instanciation

  // ─── Couleurs de marque (logo PetCare) ─────────────────────────────────
  /// Vert menthe de la marque (boutons pleins, carte active).
  static const Color primary = Color(0xFF2E9E6B);

  /// Vert menthe foncé (états pressés, textes verts sur fond clair).
  static const Color primaryDark = Color(0xFF237A52);

  /// Corail de la marque (accent : patte du logo, liens, surlignages).
  static const Color accent = Color(0xFFE8705A);
  static const Color accentTint = Color(0xFFFCE9E4);

  /// Ardoise de la marque (titres « PetCare », texte fort).
  static const Color textStrong = Color(0xFF37474F);

  /// Fond menthe très clair : puces de statut, pastilles d'icônes, sections.
  static const Color mint = Color(0xFFE7F4EC);

  /// Teinte bleutée : boutons secondaires doux (ex. « Ajouter »).
  static const Color infoTint = Color(0xFFEAF1FB);
  static const Color onInfo = Color(0xFF2B5BA7);

  /// Zone de danger (déconnexion) : rouge + fond rosé.
  static const Color danger = Color(0xFFD64545);
  static const Color dangerTint = Color(0xFFFDECEC);

  // ─── Surfaces & textes ─────────────────────────────────────────────────
  static const Color scaffold = Color(0xFFF5F7F8); // fond d'écran
  static const Color card = Colors.white;           // cartes
  static const Color border = Color(0xFFE6E8EB);     // bordures fines
  static const Color textMuted = Color(0xFF6B7280);  // texte secondaire

  // ─── Formes & espacements ──────────────────────────────────────────────
  static const double radius = 16;   // rayon des cartes
  static const double chipRadius = 24;
  static const double gap = 16;      // espacement standard

  /// Décoration standard d'une carte blanche (coins arrondis + ombre douce).
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
    boxShadow: const [
      BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );
}