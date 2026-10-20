package com.petcare;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.config.EnableMongoAuditing;

/**
 * Point d'entrée de l'API Pet-Care.
 *
 * <p>Monolithe modulaire : chaque module métier (user, pet, medicalrecord,
 * marketplace, agenda, event) vit dans son propre package et expose son API via
 * une couche controller/service/repository. Voir docs/ARCHITECTURE.md.</p>
 */
@SpringBootApplication
@EnableMongoAuditing // active @CreatedDate / @LastModifiedDate
public class PetCareApplication {

    public static void main(String[] args) {
        SpringApplication.run(PetCareApplication.class, args);
    }
}
