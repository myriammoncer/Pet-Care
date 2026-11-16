package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import java.util.List;

/**
 * Données de référence pour la catégorie HYGIÈNE & SOINS.
 * 5 produits uniques, 1 produit = 1 image unique du dossier
 * {@code assets/images/marketplace/hygiene/}.
 */
public final class HygieneSoinsSeedData {

    private HygieneSoinsSeedData() {
    }

    public static List<Product> products() {
        return List.of(
            Product.builder().name("Shampoing Doux & Lingettes Soin")
                .description("Formule hypoallergénique aux extraits d'aloe vera et d'avoine bio, pour un pelage soyeux et une peau apaisée.")
                .category(ProductCategory.HYGIENE_SOINS).photoUrl("assets/images/marketplace/hygiene/Shampooings-lingettes-chats-1.jpg")
                .price(19.90).currency("EUR").stock(30).active(true).build(),
            Product.builder().name("Brosse Démêlante Ergonomique")
                .description("Brosse à picots souples en acier inoxydable avec manche antidérapant, retire les nœuds sans tirer le poil.")
                .category(ProductCategory.HYGIENE_SOINS).photoUrl("assets/images/marketplace/hygiene/ch7020_25.jpeg")
                .price(16.50).currency("EUR").stock(40).active(true).build(),
            Product.builder().name("Spray Nettoyant Oreilles")
                .description("Solution auriculaire douce à la camomille et calendula, prévient les infections et dissout le cérumen en douceur.")
                .category(ProductCategory.HYGIENE_SOINS).photoUrl("assets/images/marketplace/hygiene/images.jpg")
                .price(12.90).currency("EUR").stock(50).active(true).build(),
            Product.builder().name("Kit Coupe-Griffes Professionnel")
                .description("Coupe-griffes en acier chirurgical avec butée de sécurité et lime intégrée, adapté à toutes les tailles d'animaux.")
                .category(ProductCategory.HYGIENE_SOINS).photoUrl("assets/images/marketplace/hygiene/images (1).jpg")
                .price(14.90).currency("EUR").stock(35).active(true).build(),
            Product.builder().name("Dentifrice Enzymatique Menthe")
                .description("Gel dentaire sans rinçage aux enzymes actives et menthe fraîche, prévient le tartre et les maladies parodontales.")
                .category(ProductCategory.HYGIENE_SOINS).photoUrl("assets/images/marketplace/hygiene/images (2).jpg")
                .price(11.50).currency("EUR").stock(45).active(true).build()
        );
    }
}