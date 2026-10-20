package com.petcare.medicalrecord.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record MedicationRequest(
        @NotBlank String name,
        @NotBlank String dosage,
        String frequency,
        @NotNull LocalDate startDate,
        LocalDate endDate
) {
}
