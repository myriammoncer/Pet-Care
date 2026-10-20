package com.petcare.user.domain;

/**
 * Rôles applicatifs contrôlant l'accès aux fonctionnalités (RBAC).
 * Voir docs/SECURITY.md.
 */
public enum Role {
    /** Administrateur : supervision globale de la plateforme. */
    ADMIN,
    /** Propriétaire d'animal : gère ses animaux et données associées. */
    PET_OWNER,
    /** Vétérinaire : accède aux dossiers médicaux des animaux suivis. */
    VET
}
