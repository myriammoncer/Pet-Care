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

import java.util.Set;

/**
 * Crée un compte administrateur par défaut et quelques produits de démonstration
 * au premier démarrage. Activé uniquement si {@code petcare.seed.enabled=true}
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
                productRepository.save(Product.builder().name("Croquettes chien adulte 12kg")
                        .description("Nourriture complète pour chien adulte").category(ProductCategory.FOOD)
                        .price(39.90).stock(50).active(true).build());
                productRepository.save(Product.builder().name("Laisse réglable")
                        .description("Laisse en nylon résistant").category(ProductCategory.ACCESSORIES)
                        .price(14.50).stock(80).active(true).build());
                productRepository.save(Product.builder().name("Balle interactive")
                        .description("Jouet distributeur de friandises").category(ProductCategory.TOYS)
                        .price(9.99).stock(120).active(true).build());
                productRepository.save(Product.builder().name("Shampoing doux chat")
                        .description("Shampoing hypoallergénique").category(ProductCategory.HYGIENE)
                        .price(11.20).stock(60).active(true).build());
                log.info("Seed: 4 produits de démonstration créés");
            }
        };
    }
}
