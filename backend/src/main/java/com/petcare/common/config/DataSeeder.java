package com.petcare.common.config;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import com.petcare.marketplace.repository.ProductRepository;
import com.petcare.marketplace.service.AccessoiresSeedData;
import com.petcare.marketplace.service.AlimentationSeedData;
import com.petcare.marketplace.service.HygieneSoinsSeedData;
import com.petcare.marketplace.service.JouetsSeedData;
import com.petcare.marketplace.service.NicheCouchageSeedData;
import com.petcare.marketplace.service.TransportSeedData;
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

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * Cr\u00e9e un compte administrateur par d\u00e9faut et quelques produits de d\u00e9monstration
 * au premier d\u00e9marrage. Activ\u00e9 uniquement si \petcare.seed.enabled=true\
 * (profil local). \u00c0 NE PAS activer en production.
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
                log.info("Seed: compte admin cr\u00e9\u00e9 ({} / Admin123!)", ADMIN_EMAIL);
            }

            // ════════════════════════════════════════════════════════════════════════
            // PURGE DES DOUBLONS : suppression de toutes les catégories existantes
            // avant re-seeding pour garantir l'intégrité des données.
            // ════════════════════════════════════════════════════════════════════════
            productRepository.deleteAllByCategory(ProductCategory.ALIMENTATION);
            productRepository.deleteAllByCategory(ProductCategory.JOUETS);
            productRepository.deleteAllByCategory(ProductCategory.NICHE_COUCHAGE);
            productRepository.deleteAllByCategory(ProductCategory.HYGIENE_SOINS);
            productRepository.deleteAllByCategory(ProductCategory.ACCESSORIES);
            productRepository.deleteAllByCategory(ProductCategory.TRANSPORT);
            log.info("Seed: toutes les catégories purgées (suppression des doublons)");

            // ═══════════════════════════════════════════════════════════════════════
            // ALIMENTATION (10 produits uniques — 1 produit = 1 image unique)
            // ════════════════════════════════════════════════════════════════════════
            final List<Product> alimentationProducts = AlimentationSeedData.products();

            // JOUETS (5 produits uniques — 1 produit = 1 image unique)
            final List<Product> jouetsProducts = JouetsSeedData.products();

            // NICHE & COUCHAGE (6 produits uniques — 1 produit = 1 image unique)
            final List<Product> nicheCouchageProducts = NicheCouchageSeedData.products();

            // HYGIÈNE & SOINS (5 produits uniques — 1 produit = 1 image unique)
            final List<Product> hygieneSoinsProducts = HygieneSoinsSeedData.products();

            // ACCESSOIRES (5 produits uniques — 1 produit = 1 image unique)
            final List<Product> accessoiresProducts = AccessoiresSeedData.products();

            // TRANSPORT (1 produit unique — 1 produit = 1 image unique)
            final List<Product> transportProducts = TransportSeedData.products();

            if (productRepository.count() == 0) {
                List<Product> allProducts = new ArrayList<>();
                allProducts.addAll(alimentationProducts);
                allProducts.addAll(jouetsProducts);
                allProducts.addAll(nicheCouchageProducts);
                allProducts.addAll(hygieneSoinsProducts);
                allProducts.addAll(accessoiresProducts);
                allProducts.addAll(transportProducts);

                productRepository.saveAll(allProducts);
                log.info("Seed: {} produits de démonstration créés pour toutes les catégories", allProducts.size());
            } else {
                // Re-seed de toutes les catégories pour garantir l'intégrité
                productRepository.saveAll(alimentationProducts);
                productRepository.saveAll(jouetsProducts);
                productRepository.saveAll(nicheCouchageProducts);
                productRepository.saveAll(hygieneSoinsProducts);
                productRepository.saveAll(accessoiresProducts);
                productRepository.saveAll(transportProducts);

                int total = alimentationProducts.size() + jouetsProducts.size()
                          + nicheCouchageProducts.size() + hygieneSoinsProducts.size()
                          + accessoiresProducts.size() + transportProducts.size();
                log.info("Seed: {} produits (re)créés pour toutes les catégories avec images uniques", total);
            }
        };
    }
}