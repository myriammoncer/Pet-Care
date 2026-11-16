package com.petcare.event.domain;

import com.petcare.common.domain.AuditableDocument;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Événement communautaire (collection {@code events}).
 * Les participants sont embarqués (relation ∞–∞ Event ↔ Users, voir DATA_MODEL.md).
 */
@Document(collection = "events")
@CompoundIndex(name = "participants_user_idx", def = "{'participants.userId': 1}")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Event extends AuditableDocument {

    private String title;
    private String description;

    @Indexed
    private EventType type;

    @Indexed
    private Instant startAt;
    private Instant endAt;

    private String location;
    private int capacity;

    @Builder.Default
    private List<Participant> participants = new ArrayList<>();

    /** Admin organisateur. */
    private String createdBy;

    public boolean isFull() {
        return participants.size() >= capacity;
    }

    /** Vrai si l'événement a déjà commencé (plus d'inscription / désinscription). */
    public boolean hasStarted(Instant now) {
        return startAt != null && !startAt.isAfter(now);
    }

    /** Inscription de l'utilisateur donné, s'il y en a une. */
    public Optional<Participant> findParticipant(String userId) {
        if (userId == null) {
            return Optional.empty();
        }
        return participants.stream().filter(p -> userId.equals(p.getUserId())).findFirst();
    }

    public boolean isRegistered(String userId) {
        return findParticipant(userId).isPresent();
    }

    /** Inscription d'un participant (utilisateur + animal). */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Participant {
        private String userId;
        private String petId;
        private Instant registeredAt;
    }
}
