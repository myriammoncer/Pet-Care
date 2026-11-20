package com.petcare.event.dto;

import com.petcare.event.domain.Event;
import com.petcare.event.domain.EventType;

import java.time.Instant;

/**
 * Vue d'un événement. {@code registered} et {@code myPetId} sont calculés pour
 * l'utilisateur courant (l'app sait ainsi s'il faut afficher « S'inscrire » ou
 * « Se désinscrire ») ; la liste nominative des participants n'est exposée qu'à
 * l'admin via {@code GET /events/{id}/participants}.
 */
public record EventResponse(
        String id,
        String title,
        String description,
        EventType type,
        Instant startAt,
        Instant endAt,
        String location,
        int capacity,
        int registeredCount,
        boolean full,
        boolean registered,
        String myPetId,
        String createdBy
) {
    public static EventResponse from(Event e) {
        return from(e, null);
    }

    public static EventResponse from(Event e, String currentUserId) {
        Event.Participant me = e.findParticipant(currentUserId).orElse(null);
        return new EventResponse(e.getId(), e.getTitle(), e.getDescription(), e.getType(),
                e.getStartAt(), e.getEndAt(), e.getLocation(), e.getCapacity(),
                e.getParticipants().size(), e.isFull(),
                me != null, me != null ? me.getPetId() : null, e.getCreatedBy());
    }
}
