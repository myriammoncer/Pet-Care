package com.petcare.user.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

/**
 * Envoi d'emails via SMTP (spring-boot-starter-mail / JavaMailSender).
 *
 * La configuration SMTP vient de application.yml (spring.mail.*), alimentée par des
 * variables d'environnement (MAIL_HOST, MAIL_USERNAME, MAIL_PASSWORD…) — jamais
 * committées. Si le SMTP n'est pas configuré, l'envoi échoue et l'appelant
 * (PasswordResetServiceImpl) capte l'exception sans bloquer la réponse.
 */
@Service
public class EmailServiceImpl implements EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailServiceImpl.class);
    private static final long TTL_MINUTES = 30;

    private final JavaMailSender mailSender;
    private final String from;

    public EmailServiceImpl(JavaMailSender mailSender,
                            @Value("${petcare.mail.from:Pet-Care <no-reply@petcare.app>}") String from) {
        this.mailSender = mailSender;
        this.from = from;
    }

    @Override
    public void sendPasswordReset(String to, String token) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(to);
        message.setSubject("Réinitialisation de ton mot de passe Pet-Care");
        message.setText(
                "Bonjour,\n\n" +
                "Tu as demandé la réinitialisation de ton mot de passe Pet-Care.\n\n" +
                "Voici ton jeton de réinitialisation (valable " + TTL_MINUTES + " minutes) :\n\n" +
                token + "\n\n" +
                "Dans l'application : « Mot de passe oublié » → « J'ai mon jeton », " +
                "colle ce jeton puis choisis un nouveau mot de passe.\n\n" +
                "Si tu n'es pas à l'origine de cette demande, ignore simplement cet email.\n\n" +
                "— L'équipe Pet-Care");
        mailSender.send(message);
        log.info("Email de réinitialisation envoyé à {}", to);
    }
}
