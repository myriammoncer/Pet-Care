package com.petcare.user.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.user.dto.ForgotPasswordRequest;
import com.petcare.user.dto.ResetPasswordRequest;
import com.petcare.user.service.PasswordResetService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Endpoints publics de réinitialisation de mot de passe.
 * Contrôleur séparé d'AuthController : aucune collision de routes.
 */
@RestController
@RequestMapping("/auth")
public class PasswordResetController {

    private final PasswordResetService service;

    public PasswordResetController(PasswordResetService service) {
        this.service = service;
    }

    /** Étape 1 : l'utilisateur demande un lien de réinitialisation. */
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<String>> forgot(
            @Valid @RequestBody ForgotPasswordRequest request) {
        // devToken = le jeton en clair en mode dev, sinon null.
        String devToken = service.forgotPassword(request);
        return ResponseEntity.ok(ApiResponse.ok(devToken,
                "Si un compte existe pour cet email, un lien de réinitialisation a été envoyé."));
    }

    /** Étape 2 : l'utilisateur fournit le jeton reçu + un nouveau mot de passe. */
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> reset(
            @Valid @RequestBody ResetPasswordRequest request) {
        service.resetPassword(request);
        return ResponseEntity.ok(ApiResponse.<Void>ok(null,
                "Mot de passe mis à jour. Tu peux te reconnecter."));
    }
}