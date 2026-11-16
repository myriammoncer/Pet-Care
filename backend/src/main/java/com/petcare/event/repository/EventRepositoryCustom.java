package com.petcare.event.repository;

import com.petcare.event.domain.Event;
import com.petcare.event.domain.EventType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.Instant;

/** Requêtes spécifiques au module (MongoTemplate). */
public interface EventRepositoryCustom {

    /** Recherche avec filtres optionnels sur le type et la période de début. */
    Page<Event> search(EventType type, Instant from, Instant to, Pageable pageable);

    /**
     * Ajoute un participant de façon <b>atomique</b> : l'écriture n'a lieu que si
     * l'utilisateur n'est pas déjà inscrit et qu'il reste une place (capacité
     * inchangée depuis la lecture). Évite les surréservations en cas d'inscriptions
     * simultanées.
     *
     * @return {@code true} si le participant a été ajouté
     */
    boolean addParticipant(String eventId, int expectedCapacity, Event.Participant participant);

    /** Retire atomiquement l'inscription d'un utilisateur. @return {@code true} si retirée. */
    boolean removeParticipant(String eventId, String userId);
}
