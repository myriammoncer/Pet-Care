package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import java.util.List;

/**
 * Données de référence pour la catégorie JOUETS.
 * 5 produits uniques, 1 produit = 1 image unique du dossier
 * {@code assets/images/marketplace/jouets/}.
 */
public final class JouetsSeedData {

    private JouetsSeedData() {
    }

    public static List<Product> products() {
        return List.of(
            Product.builder().name("Balle Rebondissante Haute Résistance")
                .description("Caoutchouc naturel non toxique, conçue pour les séances de jeu intenses et interactives avec votre compagnon.")
                .category(ProductCategory.JOUETS).photoUrl("assets/images/marketplace/jouets/cc587551-1933-4a44-af53-9662d381085c.jpg")
                .price(14.50).currency("EUR").stock(45).active(true).build(),
            Product.builder().name("Peluche Artisanale Sur Mesure")
                .description("Peluche douce cousue main avec rembourrage hypoallergénique, compagnon câlin idéal pour chiot et petit chien.")
                .category(ProductCategory.JOUETS).photoUrl("assets/images/marketplace/jouets/PELUCHE-SUR-MESURE-JAPHY-BEASTIZZ.jpg")
                .price(24.90).currency("EUR").stock(20).active(true).build(),
            Product.builder().name("Corde Tressée Multi-Nœuds")
                .description("Corde en coton naturel tressé résistant, parfaite pour le tir à la corde et le nettoyage naturel des dents.")
                .category(ProductCategory.JOUETS).photoUrl("assets/images/marketplace/jouets/3009665_73.jpg")
                .price(11.90).currency("EUR").stock(60).active(true).build(),
            Product.builder().name("Jouet Distributeur de Friandises")
                .description("Jouet interactif intelligent qui stimule l'instinct de recherche et distribue des récompenses progressivement.")
                .category(ProductCategory.JOUETS).photoUrl("assets/images/marketplace/jouets/61BTxkFttYL.jpg")
                .price(19.90).currency("EUR").stock(30).active(true).build(),
            Product.builder().name("Frisbee Souple Ultra-Léger")
                .description("Disque volant en silicone souple, doux pour les gencives et ultra-visible grâce à ses couleurs vives.")
                .category(ProductCategory.JOUETS).photoUrl("assets/images/marketplace/jouets/VoDb48M9IEfv5qRk21Fu7dm0pMUeeRaMhtRdDa45.jpg")
                .price(12.50).currency("EUR").stock(38).active(true).build()
        );
    }
}