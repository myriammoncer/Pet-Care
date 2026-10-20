package com.petcare.agenda.dto;

import com.petcare.agenda.domain.AgendaItemType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;

public record AgendaItemRequest(
        @NotBlank String petId,
        @NotNull AgendaItemType type,
        @NotBlank String title,
        String notes,
        @NotNull Instant scheduledAt,
        Instant reminderAt,
        String recurrence
) {
}
