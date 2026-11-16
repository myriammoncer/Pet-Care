package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import java.util.List;

/**
 * Données de référence pour la catégorie NICHE & COUCHAGE.
 * 6 produits uniques, 1 produit = 1 image unique du dossier
 * {@code assets/images/marketplace/couchage/}.
 */
public final class NicheCouchageSeedData {

    private NicheCouchageSeedData() {
    }

    public static List<Product> products() {
        return List.of(
            Product.builder().name("Niche Artisanale en Bois Noble")
                .description("Finitions artisanales en bois massif traité, isolation thermique naturelle et toit amovible pour un entretien facile.")
                .category(ProductCategory.NICHE_COUCHAGE).photoUrl("assets/images/marketplace/couchage/Niche-de-chien-en-bois-Dogue-de-Bordeaux.jpg")
                .price(129.00).currency("EUR").stock(5).active(true).build(),
            Product.builder().name("Coussin Ovale Velours Premium")
                .description("Coussin moelleux en velours lavable avec mousse à mémoire de forme, soutien orthopédique pour un repos optimal.")
                .category(ProductCategory.NICHE_COUCHAGE).photoUrl("assets/images/marketplace/couchage/c9635653c1ccc747ca09a947052f637fd9ba4624_original.jpeg")
                .price(49.90).currency("EUR").stock(18).active(true).build(),
            Product.builder().name("Panier Design Scandinave")
                .description("Panier en feutre écologique aux lignes épurées, structure auto-portante et fond déhoussable lavable en machine.")
                .category(ProductCategory.NICHE_COUCHAGE).photoUrl("assets/images/marketplace/couchage/istockphoto-1125630990-612x612.jpg")
                .price(59.00).currency("EUR").stock(14).active(true).build(),
            Product.builder().name("Lit Surélevé Respirant")
                .description("Structure en aluminium léger avec toile mesh respirante, idéal pour l'été et les animaux souffrant d'arthrose.")
                .category(ProductCategory.NICHE_COUCHAGE).photoUrl("assets/images/marketplace/couchage/istockphoto-173656433-612x612.jpg")
                .price(44.50).currency("EUR").stock(10).active(true).build(),
            Product.builder().name("Maisonnette Chat Cocooning")
                .description("Cabane fermée en peluche douce avec ouverture arrondie, refuge idéal pour les siestes et moments de tranquillité.")
                .category(ProductCategory.NICHE_COUCHAGE).photoUrl("assets/images/marketplace/couchage/61peyr242mL._AC_UF1000,1000_QL80_.jpg")
                .price(39.90).currency("EUR").stock(22).active(true).build(),
            Product.builder().name("Matelas Orthopédique Grande Taille")
                .description("Matelas XL en mousse haute densité avec housse imperméable et antidérapant, conçu pour les grandes races.")
                .category(ProductCategory.NICHE_COUCHAGE).photoUrl("assets/images/marketplace/couchage/71kUAVpKoaL._AC_UL375_SR375,375_.jpg")
                .price(79.00).currency("EUR").stock(8).active(true).build()
        );
    }
}