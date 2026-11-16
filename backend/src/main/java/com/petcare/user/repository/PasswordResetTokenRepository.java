package com.petcare.user.repository;

import com.petcare.user.domain.PasswordResetToken;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

/** Accès Mongo aux jetons de réinitialisation. */
public interface PasswordResetTokenRepository
        extends MongoRepository<PasswordResetToken, String> {

    /** Retrouve un jeton par son empreinte (pour valider une demande de reset). */
    Optional<PasswordResetToken> findByTokenHash(String tokenHash);
}