package com.petcare.user.domain;

import com.petcare.common.domain.AuditableDocument;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.HashSet;
import java.util.Set;

/**
 * Compte utilisateur de la plateforme (collection {@code users}).
 * Le mot de passe est stocké haché (BCrypt) et n'est jamais exposé par l'API.
 */
@Document(collection = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends AuditableDocument {

    @Indexed(unique = true)
    private String email;

    /** Mot de passe haché (BCrypt). */
    private String password;

    private String firstName;
    private String lastName;
    private String phone;

    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    @Builder.Default
    private boolean enabled = true;

    public String fullName() {
        return "%s %s".formatted(firstName == null ? "" : firstName,
                lastName == null ? "" : lastName).trim();
    }
}
