package com.petcare.common.config;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import com.petcare.marketplace.repository.ProductRepository;
import com.petcare.user.domain.Role;
import com.petcare.user.domain.User;
import com.petcare.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;
import java.util.Set;

/**
 * Crée un compte administrateur par défaut et quelques produits de démonstration
 * au premier démarrage. Activé uniquement si `petcare.seed.enabled=true`
 * (profil local). À NE PAS activer en production.
 */
@Configuration
@ConditionalOnProperty(name = "petcare.seed.enabled", havingValue = "true")
public class DataSeeder {

    private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);
    private static final String ADMIN_EMAIL = "admin@petcare.app";

    @Bean
    ApplicationRunner seed(UserRepository userRepository, ProductRepository productRepository,
                           PasswordEncoder passwordEncoder) {
        return args -> {
            if (!userRepository.existsByEmail(ADMIN_EMAIL)) {
                userRepository.save(User.builder()
                        .email(ADMIN_EMAIL)
                        .password(passwordEncoder.encode("Admin123!"))
                        .firstName("Admin")
                        .lastName("Pet-Care")
                        .roles(Set.of(Role.ADMIN))
                        .enabled(true)
                        .build());
                log.info("Seed: compte admin créé ({} / Admin123!)", ADMIN_EMAIL);
            }

            if (productRepository.count() == 0) {
                List<Product> products = List.of(
                    // ───── ALIMENTATION (10) ─────
                    Product.builder().name("Croquettes Bio Premium Saumon")
                        .description("Riches en saumon frais et super-aliments, formulées sans céréales, sac de 5 kg pour une vitalité optimale et un pelage éclatant.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/DogFood.jpg")
                        .price(34.99).currency("EUR").stock(20).active(true).build(),
                    Product.builder().name("Pack Découverte Made in France")
                        .description("Assortiment gourmand fabriqué en France : croquettes, pâtées et friandises naturelles pour chien exigeant.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/pack-decouverte-made-in-france-alimentation-pour-chien.jpg")
                        .price(42.90).currency("EUR").stock(12).active(true).build(),
                    Product.builder().name("Croquettes Chat Adulte Poulet & Riz")
                        .description("Recette équilibrée à base de poulet fermier et riz complet, enrichie en taurine pour la santé cardiaque du chat.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/meilleurs-croquettes-pour-chats-comparatif-header-mobile.jpg")
                        .price(27.50).currency("EUR").stock(35).active(true).build(),
                    Product.builder().name("Pâtée Gold Miel & Fusion Nutribird")
                        .description("Alimentation premium pour oiseaux, enrichie au miel naturel et vitamines essentielles pour un plumage vibrant.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/gold-patee-honey-fusion-nutribird-versele-laga.jpg")
                        .price(18.90).currency("EUR").stock(40).active(true).build(),
                    Product.builder().name("Alimentation Naturelle Chiot")
                        .description("Formule spéciale croissance avec DHA, protéines de haute qualité et calcium pour le développement osseux du chiot.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/AdobeStock_161582709.jpeg")
                        .price(31.00).currency("EUR").stock(18).active(true).build(),
                    Product.builder().name("Repas Complet Bio pour Chat")
                        .description("Nourriture complète certifiée bio, à base de viande fraîche et légumes de saison, sans conservateurs artificiels.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/ChatGPT-Image-4-sept.-2025-18_00_57-1280x853.png")
                        .price(23.50).currency("EUR").stock(28).active(true).build(),
                    Product.builder().name("Croquettes Hypoallergéniques Agneau")
                        .description("Formule mono-protéine à l'agneau pour les chiens sensibles, sans gluten ni additifs, digestion douce garantie.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/dog-food-allergies-yeast-diet-guide-pmp.webp")
                        .price(38.90).currency("EUR").stock(15).active(true).build(),
                    Product.builder().name("Friandises Dentaires Bâtonnets")
                        .description("Bâtonnets à mâcher enrichis en menthe et enzymes naturelles pour une haleine fraîche et des dents saines.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/images.jpg")
                        .price(9.90).currency("EUR").stock(55).active(true).build(),
                    Product.builder().name("Boîtes Pâté Gourmet Bœuf & Légumes")
                        .description("Pâté onctueux au bœuf sélectionné et petits légumes du jardin, source de protéines nobles et oméga-3.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/images (1).jpg")
                        .price(15.90).currency("EUR").stock(32).active(true).build(),
                    Product.builder().name("Complément Alimentaire Vitalité+")
                        .description("Supplément en poudre aux vitamines B, zinc et levure de bière pour renforcer l'immunité et la beauté du poil.")
                        .category(ProductCategory.ALIMENTATION).photoUrl("assets/images/marketplace/alimentation/images (2).jpg")
                        .price(22.00).currency("EUR").stock(24).active(true).build(),

                    // ───── JOUETS (5) ─────
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
                        .price(12.50).currency("EUR").stock(38).active(true).build(),

                    // ───── NICHE & COUCHAGE (6) ─────
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
                        .description("Matelas XL en mousse haute densité avec housse imperméable et antidérapante, conçu pour les grandes races.")
                        .category(ProductCategory.NICHE_COUCHAGE).photoUrl("assets/images/marketplace/couchage/71kUAVpKoaL._AC_UL375_SR375,375_.jpg")
                        .price(79.00).currency("EUR").stock(8).active(true).build(),

                    // ───── HYGIÈNE & SOINS (5) ─────
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
                        .price(11.50).currency("EUR").stock(45).active(true).build(),

                    // ───── ACCESSOIRES (5) ─────
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
                        .price(34.90).currency("EUR").stock(16).active(true).build(),

                    // ───── TRANSPORT (1) ─────
                    Product.builder().name("Sac de Voyage Confort Première Classe")
                        .description("Structure renforcée respirante avec ouverture panoramique et fond rembourré amovible pour des trajets sereins.")
                        .category(ProductCategory.TRANSPORT).photoUrl("assets/images/marketplace/transport/sac_transport.jpg")
                        .price(54.00).currency("EUR").stock(8).active(true).build()
                );

                productRepository.saveAll(products);
                log.info("Seed: {} produits de démonstration créés pour toutes les catégories", products.size());
            }
        };
    }
}