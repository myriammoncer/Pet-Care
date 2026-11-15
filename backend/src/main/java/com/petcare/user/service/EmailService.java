package com.petcare.user.service;

/** Envoi d'emails liés au compte utilisateur. */
public interface EmailService {

    /** Envoie l'email de réinitialisation de mot de passe (contenant le jeton). */
    void sendPasswordReset(String to, String token);
}
