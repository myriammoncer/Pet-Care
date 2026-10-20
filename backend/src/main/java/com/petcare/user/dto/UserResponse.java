package com.petcare.user.dto;

import com.petcare.user.domain.Role;
import com.petcare.user.domain.User;

import java.util.Set;

/**
 * Représentation publique d'un utilisateur (sans le mot de passe).
 */
public record UserResponse(
        String id,
        String email,
        String firstName,
        String lastName,
        String phone,
        Set<Role> roles,
        boolean enabled
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getPhone(),
                user.getRoles(),
                user.isEnabled()
        );
    }
}
