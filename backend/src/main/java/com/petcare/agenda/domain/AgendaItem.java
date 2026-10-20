package com.petcare.agenda.domain;

import com.petcare.common.domain.AuditableDocument;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

/**
 * Élément d'agenda / rappel lié à un animal (collection {@code agenda_items}).
 */
@Document(collection = "agenda_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgendaItem extends AuditableDocument {

    @Indexed
    private String ownerId;

    @Indexed
    private String petId;

    private AgendaItemType type;
    private String title;
    private String notes;

    @Indexed
    private Instant scheduledAt;

    /** Date/heure du rappel (notification). */
    private Instant reminderAt;

    @Builder.Default
    private AgendaItemStatus status = AgendaItemStatus.SCHEDULED;

    /** Règle de récurrence optionnelle, ex. EVERY_3_MONTHS. */
    private String recurrence;
}
