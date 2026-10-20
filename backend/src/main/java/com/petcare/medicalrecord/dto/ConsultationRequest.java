package com.petcare.medicalrecord.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;

public record ConsultationRequest(
        @NotNull Instant date,
        @NotBlank String reason,
        String diagnosis,
        String notes
) {
}
