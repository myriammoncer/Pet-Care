package com.petcare;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * Vérifie que le contexte Spring démarre correctement.
 * Utilise une MongoDB embarquée (de.flapdoodle) via le profil {@code test}.
 */
@SpringBootTest
@ActiveProfiles("test")
class PetCareApplicationTests {

    @Test
    void contextLoads() {
        // Le test échoue si le contexte applicatif ne se charge pas.
    }
}
