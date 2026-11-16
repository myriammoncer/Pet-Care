package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import java.util.List;

/**
 * Données de référence pour la catégorie ACCESSOIRES.
 * 5 produits uniques, 1 produit = 1 image unique du dossier
 * {@code assets/images/marketplace/accessoires/}.
 */
public final class AccessoiresSeedData {

    private AccessoiresSeedData() {
    }

    public static List<Product> products() {
        return List.of(
            Product.builder().name("Ensemble Laisse Cuir & Harnais Réfléchissant")
                .description("Surpiqûres sellier, mousqueton en laiton brossé et inserts réfléchissants pour des promenades sûres et élégantes.")
                .category(ProductCategory.ACCESSORIES).photoUrl("assets/images/marketplace/accessoires/chien_promenade_collier_rouge_personnalise_laisse.png")
                .price(28.50).currency("EUR").stock(25).active(true).build(),
            Product.builder().name("Gamelle Double Inox Anti-Dérapante")
                .description("Double gamelle en acier inoxydable alimentaire sur support antidérapant en silicone, eau et nourriture séparées.")
                .category(ProductCategory.ACCESSORIES).photoUrl("assets/images/marketplace/accessoires/715554235.jpg")
                .price(22.90).currency("EUR").stock(30).active(true).build(),
            Product.builder().name("Médaille Gravée Personnalisable")
                .description("Médaille en alliage poli brillant, gravure laser recto-verso offerte, anneau renforcé anti-perte pour collier.")
                .category(ProductCategory.ACCESSORIES).photoUrl("assets/images/marketplace/accessoires/images.jpg")
                .price(9.90).currency("EUR").stock(70).active(true).build(),
            Product.builder().name("Bandana Chic Coton Bio")
                .description("Bandana artisanal en coton bio certifié, motifs exclusifs et attache réglable, parfait pour les sorties mode.")
                .category(ProductCategory.ACCESSORIES).photoUrl("assets/images/marketplace/accessoires/images (1).jpg")
                .price(13.50).currency("EUR").stock(55).active(true).build(),
            Product.builder().name("Fontaine à Eau Silencieuse 2L")
                .description("Fontaine avec filtre charbon actif et pompe ultra-silencieuse, encourage l'hydratation grâce à l'eau en mouvement.")
                .category(ProductCategory.ACCESSORIES).photoUrl("assets/images/marketplace/accessoires/images (2).jpg")
                .price(34.90).currency("EUR").stock(16).active(true).build()
        );
    }
}