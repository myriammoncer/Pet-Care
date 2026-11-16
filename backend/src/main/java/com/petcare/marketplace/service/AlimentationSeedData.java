package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import java.util.List;

/**
 * Données de référence pour la catégorie ALIMENTATION.
 * Garantit exactement 10 produits uniques, chacun associé de façon biunivoque
 * à l'une des 10 images du dossier {@code assets/images/marketplace/alimentation/}.
 * Utilisé par {@link DataSeeder} (démarrage) et {@link ProductServiceImpl} (re-seed à la demande).
 */
public final class AlimentationSeedData {

    private AlimentationSeedData() {
    }

    public static List<Product> products() {
        return List.of(
            // 1
            Product.builder().name("Croquettes Bio Premium Saumon")
                .description("Riches en saumon frais et super-aliments, formulées sans céréales, sac de 5 kg pour une vitalité optimale et un pelage éclatant.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/DogFood.jpg")
                .price(34.99).currency("EUR").stock(20).active(true).build(),
            // 2
            Product.builder().name("Pack Découverte Made in France")
                .description("Assortiment gourmand fabriqué en France : croquettes, pâtées et friandises naturelles pour chien exigeant.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/pack-decouverte-made-in-france-alimentation-pour-chien.jpg")
                .price(42.90).currency("EUR").stock(12).active(true).build(),
            // 3
            Product.builder().name("Croquettes Chat Adulte Poulet & Riz")
                .description("Recette équilibrée à base de poulet fermier et riz complet, enrichie en taurine pour la santé cardiaque du chat.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/meilleurs-croquettes-pour-chats-comparatif-header-mobile.jpg")
                .price(27.50).currency("EUR").stock(35).active(true).build(),
            // 4
            Product.builder().name("Pâtée Gold Miel & Fusion Nutribird")
                .description("Alimentation premium pour oiseaux, enrichie au miel naturel et vitamines essentielles pour un plumage vibrant.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/gold-patee-honey-fusion-nutribird-versele-laga.jpg")
                .price(18.90).currency("EUR").stock(40).active(true).build(),
            // 5
            Product.builder().name("Alimentation Naturelle Chiot")
                .description("Formule spéciale croissance avec DHA, protéines de haute qualité et calcium pour le développement osseux du chiot.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/AdobeStock_161582709.jpeg")
                .price(31.00).currency("EUR").stock(18).active(true).build(),
            // 6
            Product.builder().name("Repas Complet Bio pour Chat")
                .description("Nourriture complète certifiée bio, à base de viande fraîche et légumes de saison, sans conservateurs artificiels.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/ChatGPT-Image-4-sept.-2025-18_00_57-1280x853.png")
                .price(23.50).currency("EUR").stock(28).active(true).build(),
            // 7
            Product.builder().name("Croquettes Hypoallergéniques Agneau")
                .description("Formule mono-protéine à l'agneau pour les chiens sensibles, sans gluten ni additifs, digestion douce garantie.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/dog-food-allergies-yeast-diet-guide-pmp.webp")
                .price(38.90).currency("EUR").stock(15).active(true).build(),
            // 8
            Product.builder().name("Friandises Dentaires Bâtonnets")
                .description("Bâtonnets à mâcher enrichis en menthe et enzymes naturelles pour une haleine fraîche et des dents saines.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/images.jpg")
                .price(9.90).currency("EUR").stock(55).active(true).build(),
            // 9
            Product.builder().name("Boîtes Pâté Gourmet Bœuf & Légumes")
                .description("Pâté onctueux au bœuf sélectionné et petits légumes du jardin, source de protéines nobles et oméga-3.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/images (1).jpg")
                .price(15.90).currency("EUR").stock(32).active(true).build(),
            // 10
            Product.builder().name("Complément Alimentaire Vitalité+")
                .description("Supplément en poudre aux vitamines B, zinc et levure de bière pour renforcer l'immunité et la beauté du poil.")
                .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/images (2).jpg")
                .price(22.00).currency("EUR").stock(24).active(true).build()
        );
    }
}