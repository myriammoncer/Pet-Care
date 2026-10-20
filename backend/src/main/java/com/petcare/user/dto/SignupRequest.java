package com.petcare.user.dto;

import com.petcare.user.domain.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Requête d'inscription. Le rôle demandé est limité à PET_OWNER ou VET
 * (la création d'un ADMIN se fait par un autre admin).
 */
public record SignupRequest(
        @NotBlank @Email String email,
        @NotBlank @Size(min = 8, message = "Le mot de passe doit contenir au moins 8 caractères") String password,
        @NotBlank String firstName,
        @NotBlank String lastName,
        String phone,
        @NotNull Role role
) {
}
