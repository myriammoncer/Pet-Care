package com.petcare.event.config;

import com.petcare.event.domain.Event;
import com.petcare.event.domain.EventType;
import com.petcare.event.repository.EventRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * Événements de démonstration (module Événements), créés si la collection est vide.
 * Même condition que le seed commun : {@code petcare.seed.enabled=true} (profil local).
 */
@Configuration
@ConditionalOnProperty(name = "petcare.seed.enabled", havingValue = "true")
public class EventDataSeeder {

    private static final Logger log = LoggerFactory.getLogger(EventDataSeeder.class);

    @Bean
    ApplicationRunner seedEvents(EventRepository repository) {
        return args -> {
            if (repository.count() > 0) {
                return;
            }
            Instant base = Instant.now().truncatedTo(ChronoUnit.HOURS);
            List<Event> events = List.of(
                    demo("Promenade collective au parc", EventType.GROUP_WALK,
                            "Balade de 5 km en groupe, chiens tenus en laisse. Point d'eau prévu.",
                            "Parc du Belvédère, Tunis", base.plus(Duration.ofDays(3)).plus(Duration.ofHours(9)), 2, 25),
                    demo("Journée santé : vaccination & bilan", EventType.HEALTH_DAY,
                            "Bilan de santé gratuit et campagne de vaccination avec nos vétérinaires partenaires.",
                            "Clinique vétérinaire Les Berges", base.plus(Duration.ofDays(7)).plus(Duration.ofHours(10)), 6, 40),
                    demo("Concours de beauté canin & félin", EventType.BEAUTY_CONTEST,
                            "Défilé, jury et remise de prix. Inscription d'un animal par participant.",
                            "Salle des fêtes, La Marsa", base.plus(Duration.ofDays(12)).plus(Duration.ofHours(15)), 3, 30),
                    demo("Journée adoption", EventType.ADOPTION,
                            "Rencontrez des animaux en attente d'une famille, en partenariat avec les refuges.",
                            "Place de l'Indépendance", base.plus(Duration.ofDays(18)).plus(Duration.ofHours(10)), 7, 100),
                    demo("Atelier éducation du chiot", EventType.TRAINING_WORKSHOP,
                            "Les bases : rappel, marche en laisse, socialisation. Places limitées.",
                            "Centre canin El Menzah", base.plus(Duration.ofDays(5)).plus(Duration.ofHours(17)), 2, 8)
            );
            repository.saveAll(events);
            log.info("Seed: {} événements de démonstration créés", events.size());
        };
    }

    private static Event demo(String title, EventType type, String description, String location,
                              Instant startAt, int durationHours, int capacity) {
        return Event.builder()
                .title(title).type(type).description(description).location(location)
                .startAt(startAt).endAt(startAt.plus(Duration.ofHours(durationHours)))
                .capacity(capacity)
                .build();
    }
}
