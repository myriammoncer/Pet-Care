package com.petcare.common.dto;

/**
 * Enveloppe uniforme des réponses de l'API.
 *
 * @param success indique si la requête a réussi
 * @param data    charge utile (peut être null)
 * @param message message optionnel (succès)
 * @param error   détail d'erreur (null en cas de succès)
 */
public record ApiResponse<T>(boolean success, T data, String message, ErrorResponse error) {

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, data, null, null);
    }

    public static <T> ApiResponse<T> ok(T data, String message) {
        return new ApiResponse<>(true, data, message, null);
    }

    public static <T> ApiResponse<T> error(ErrorResponse error) {
        return new ApiResponse<>(false, null, null, error);
    }
}
