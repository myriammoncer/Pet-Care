package com.petcare.agenda.dto;

import com.petcare.agenda.domain.AgendaItemStatus;
import jakarta.validation.constraints.NotNull;

public record UpdateAgendaStatusRequest(
        @NotNull AgendaItemStatus status
) {
}
