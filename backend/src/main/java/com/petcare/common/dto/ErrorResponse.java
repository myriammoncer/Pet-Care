package com.petcare.common.dto;

import java.time.Instant;
import java.util.List;

/**
 * Corps d'erreur standardisé renvoyé par le gestionnaire global d'exceptions.
 *
 * @param code    code applicatif (ex. RESOURCE_NOT_FOUND)
 * @param message message lisible
 * @param path    chemin de la requête
 * @param details erreurs de validation éventuelles (champ -> message)
 */
public record ErrorResponse(
        String code,
        String message,
        String path,
        List<String> details,
        Instant timestamp
) {
    public static ErrorResponse of(String code, String message, String path) {
        return new ErrorResponse(code, message, path, List.of(), Instant.now());
    }

    public static ErrorResponse of(String code, String message, String path, List<String> details) {
        return new ErrorResponse(code, message, path, details, Instant.now());
    }
}
