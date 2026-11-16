import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// En-tête de section : titre à gauche, action/compte optionnel à droite.
/// Ex. maquette : « Paramètres du Compte & Sécurité », « Compagnons rattachés ».
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing; // ex. un bouton texte « Ajouter »

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Puce de statut « menthe » (ex. « Certifié », « Ordre actif », rôle).
class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.color, this.background});

  final String label;
  final Color? color;      // couleur du texte
  final Color? background;  // couleur de fond

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? AppTokens.mint,
        borderRadius: BorderRadius.circular(AppTokens.chipRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppTokens.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Carte blanche standard (coins arrondis + ombre douce), avec padding interne.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTokens.cardDecoration,
      padding: padding ?? const EdgeInsets.all(AppTokens.gap),
      child: child,
    );
  }
}