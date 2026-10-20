package com.petcare.medicalrecord.dto;

import com.petcare.medicalrecord.domain.MedicalRecord.AllergySeverity;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AllergyRequest(
        @NotBlank String substance,
        @NotNull AllergySeverity severity,
        String reaction,
        String notes
) {
}
