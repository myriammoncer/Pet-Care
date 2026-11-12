package com.petcare.user.service;

import com.petcare.common.exception.ConflictException;
import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.user.domain.PasswordResetToken;
import com.petcare.user.domain.User;
import com.petcare.user.dto.ForgotPasswordRequest;
import com.petcare.user.dto.ResetPasswordRequest;
import com.petcare.user.repository.PasswordResetTokenRepository;
import com.petcare.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Optional;

/**
 * Implémentation de la réinitialisation du mot de passe.
 *
 * Choix adaptés à un projet académique SANS serveur mail :
 * - jeton aléatoire cryptographiquement sûr (32 octets) ;
 * - on ne stocke que son HASH (SHA-256) → usage unique + expiration ;
 * - faute de SMTP, on JOURNALISE le jeton (en prod : envoi d'un email avec un lien) ;
 * - forgot-password répond toujours 200 (anti-énumération d'emails).
 *
 * Erreurs : on lève une ConflictException (mappée en 409 par ton GlobalExceptionHandler)
 * pour un jeton invalide/expiré → réponse au format ApiResponse uniforme.
 */
@Service
public class PasswordResetServiceImpl implements PasswordResetService {

    private static final Logger log = LoggerFactory.getLogger(PasswordResetServiceImpl.class);
    private static final long TOKEN_TTL_MINUTES = 30;

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final SecureRandom secureRandom = new SecureRandom();

    public PasswordResetServiceImpl(UserRepository userRepository,
                                    PasswordResetTokenRepository tokenRepository,
                                    PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.tokenRepository = tokenRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void forgotPassword(ForgotPasswordRequest request) {
        // ⚠️ Adapte le nom si ton UserRepository diffère (ex. findByEmailIgnoreCase).
        Optional<User> maybeUser = userRepository.findByEmail(request.email());

        // Réponse identique que l'email existe ou non → anti-énumération.
        if (maybeUser.isEmpty()) {
            log.info("Demande de reset pour un email inconnu : {}", request.email());
            return;
        }
        User user = maybeUser.get();

        // 1. Jeton clair (envoyé à l'utilisateur) + son hash (stocké en base).
        String rawToken = generateToken();
        String tokenHash = sha256(rawToken);

        // 2. Persiste le jeton haché avec une expiration.
        PasswordResetToken token = new PasswordResetToken(
                user.getId(),
                tokenHash,
                Instant.now().plus(TOKEN_TTL_MINUTES, ChronoUnit.MINUTES)
        );
        tokenRepository.save(token);

        // 3. « Envoi » du jeton. DEV : log. PROD : email avec un lien de reset.
        log.info("[RESET MOT DE PASSE] Jeton pour {} (valable {} min) : {}",
                user.getEmail(), TOKEN_TTL_MINUTES, rawToken);
        // TODO prod : envoyer un email vers https://app.petcare/reset?token=<rawToken>
    }

    @Override
    public void resetPassword(ResetPasswordRequest request) {
        String tokenHash = sha256(request.token());

        PasswordResetToken token = tokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new ConflictException("Jeton invalide"));

        if (token.isUsed() || token.isExpired()) {
            throw new ConflictException("Jeton expiré ou déjà utilisé");
        }

        User user = userRepository.findById(token.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", token.getUserId()));

        // Met à jour le mot de passe (haché BCrypt via le PasswordEncoder du projet).
        user.setPassword(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);

        // Usage unique : on marque le jeton comme consommé.
        token.setUsed(true);
        tokenRepository.save(token);

        log.info("Mot de passe réinitialisé pour {}", user.getEmail());
    }

    // ─── Helpers ───────────────────────────────────────────────────────────

    /** Jeton aléatoire URL-safe (32 octets → ~43 caractères). */
    private String generateToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /** Empreinte SHA-256 (hex) d'une chaîne. */
    private String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (Exception e) {
            throw new IllegalStateException("SHA-256 indisponible", e);
        }
    }
}