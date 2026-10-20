package com.petcare.pet.dto;

import com.petcare.pet.domain.Pet;
import com.petcare.pet.domain.PetStatus;
import com.petcare.pet.domain.Sex;
import com.petcare.pet.domain.Species;

import java.time.LocalDate;
import java.time.Period;

/**
 * Représentation d'un animal renvoyée par l'API (l'âge est calculé).
 */
public record PetResponse(
        String id,
        String ownerId,
        String name,
        Species species,
        String breed,
        LocalDate birthDate,
        Integer ageYears,
        Sex sex,
        Double weight,
        String color,
        String photoUrl,
        String microchipNumber,
        PetStatus status
) {
    public static PetResponse from(Pet pet) {
        Integer age = pet.getBirthDate() == null ? null
                : Period.between(pet.getBirthDate(), LocalDate.now()).getYears();
        return new PetResponse(
                pet.getId(), pet.getOwnerId(), pet.getName(), pet.getSpecies(), pet.getBreed(),
                pet.getBirthDate(), age, pet.getSex(), pet.getWeight(), pet.getColor(),
                pet.getPhotoUrl(), pet.getMicrochipNumber(), pet.getStatus()
        );
    }
}
