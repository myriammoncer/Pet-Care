import 'package:flutter/material.dart';

/// Modèle représentant une catégorie de produits dans la boutique.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;

  /// Liste des catégories disponibles dans l'application.
  static const List<Category> categories = [
    Category(id: 'ALL', name: 'Tous', icon: Icons.grid_view_rounded),
    Category(id: 'ALIMENTATION', name: 'Alimentation', icon: Icons.set_meal_outlined),
    Category(id: 'JOUETS', name: 'Jouets', icon: Icons.sports_tennis_outlined),
    Category(id: 'NICHE_COUCHAGE', name: 'Niche & Couchage', icon: Icons.bed_outlined),
    Category(id: 'HYGIENE_SOINS', name: 'Hygiène & Soins', icon: Icons.clean_hands_outlined),
    Category(id: 'TRANSPORT', name: 'Transport', icon: Icons.directions_car_outlined),
    Category(id: 'ACCESSORIES', name: 'Accessoires', icon: Icons.pets_outlined),
  ];
}
