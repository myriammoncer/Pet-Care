package com.petcare.user.domain;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

/**
 * Jeton de réinitialisation de mot de passe (collection `password_reset_tokens`).
 *
 * On stocke le HASH du jeton (jamais le jeton en clair) : même en cas de fuite de la
 * base, un attaquant ne peut pas réutiliser les jetons. Le jeton en clair n'existe
 * qu'au moment de l'« envoi » à l'utilisateur.
 */
@Document(collection = "password_reset_tokens")
public class PasswordResetToken {

    @Id
    private String id;

    /** Référence vers l'utilisateur concerné (users._id). */
    @Indexed
    private String userId;

    /** Empreinte SHA-256 du jeton (hex). On ne stocke jamais le jeton en clair. */
    private String tokenHash;

    /** Date d'expiration : le jeton n'est valable que ~30 min. */
    private Instant expiresAt;

    /** Vrai une fois le jeton consommé (usage unique). */
    private boolean used;

    public PasswordResetToken() {}

    public PasswordResetToken(String userId, String tokenHash, Instant expiresAt) {
        this.userId = userId;
        this.tokenHash = tokenHash;
        this.expiresAt = expiresAt;
        this.used = false;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getTokenHash() { return tokenHash; }
    public void setTokenHash(String tokenHash) { this.tokenHash = tokenHash; }
    public Instant getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Instant expiresAt) { this.expiresAt = expiresAt; }
    public boolean isUsed() { return used; }
    public void setUsed(boolean used) { this.used = used; }

    /** Pratique : le jeton est-il périmé ? */
    public boolean isExpired() { return Instant.now().isAfter(expiresAt); }
}