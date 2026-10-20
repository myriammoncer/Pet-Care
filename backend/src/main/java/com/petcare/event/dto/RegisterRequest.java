package com.petcare.event.dto;

import jakarta.validation.constraints.NotBlank;

/** Inscription à un événement avec l'animal participant. */
public record RegisterRequest(
        @NotBlank String petId
) {
}
