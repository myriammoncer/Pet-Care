package com.petcare.event.domain;

import com.petcare.common.domain.AuditableDocument;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Événement communautaire (collection {@code events}).
 */
@Document(collection = "events")
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
