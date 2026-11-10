package com.petcare.user.service;

import com.petcare.user.dto.ForgotPasswordRequest;
import com.petcare.user.dto.ResetPasswordRequest;

/** Logique de réinitialisation du mot de passe (contrat). */
public interface PasswordResetService {

    /** Démarre une réinitialisation : génère un jeton et l'« envoie » (log en dev). */
    void forgotPassword(ForgotPasswordRequest request);

    /** Termine la réinitialisation : valide le jeton et met à jour le mot de passe. */
    void resetPassword(ResetPasswordRequest request);
}