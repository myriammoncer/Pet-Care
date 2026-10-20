package com.petcare.agenda.dto;

import com.petcare.agenda.domain.AgendaItem;
import com.petcare.agenda.domain.AgendaItemStatus;
import com.petcare.agenda.domain.AgendaItemType;

import java.time.Instant;

public record AgendaItemResponse(
        String id,
        String ownerId,
        String petId,
        AgendaItemType type,
        String title,
        String notes,
        Instant scheduledAt,
        Instant reminderAt,
        AgendaItemStatus status,
        String recurrence
) {
    public static AgendaItemResponse from(AgendaItem i) {
        return new AgendaItemResponse(i.getId(), i.getOwnerId(), i.getPetId(), i.getType(),
                i.getTitle(), i.getNotes(), i.getScheduledAt(), i.getReminderAt(),
                i.getStatus(), i.getRecurrence());
    }
}
