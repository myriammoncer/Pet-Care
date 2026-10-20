package com.petcare.pet.dto;

import com.petcare.pet.domain.PetStatus;
import com.petcare.pet.domain.Sex;
import com.petcare.pet.domain.Species;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

import java.time.LocalDate;

/**
 * Données d'entrée pour créer / mettre à jour un animal.
 */
public record PetRequest(
        @NotBlank String name,
        @NotNull Species species,
        String breed,
        LocalDate birthDate,
        @NotNull Sex sex,
        @PositiveOrZero Double weight,
        String color,
        String photoUrl,
        String microchipNumber,
        PetStatus status
) {
}
