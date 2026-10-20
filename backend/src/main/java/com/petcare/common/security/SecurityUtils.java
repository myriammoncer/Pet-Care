package com.petcare.common.security;

import com.petcare.common.exception.ForbiddenException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Accès pratique à l'utilisateur authentifié courant (issu du JWT).
 */
public final class SecurityUtils {

    private SecurityUtils() {
    }

    /** Identifiant de l'utilisateur courant (claim {@code sub} du JWT). */
    public static String currentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getPrincipal() == null) {
            throw new ForbiddenException("No authenticated user");
        }
        return auth.getPrincipal().toString();
    }

    /** Vrai si l'utilisateur courant possède le rôle donné (sans préfixe ROLE_). */
    public static boolean hasRole(String role) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) {
            return false;
        }
        return auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_" + role));
    }

    public static boolean isAdmin() {
        return hasRole("ADMIN");
    }
}
