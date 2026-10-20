package com.petcare.common.exception;

/** Levée lorsqu'un utilisateur authentifié n'a pas le droit d'accéder à la ressource (→ HTTP 403). */
public class ForbiddenException extends RuntimeException {
    public ForbiddenException(String message) {
        super(message);
    }
}
