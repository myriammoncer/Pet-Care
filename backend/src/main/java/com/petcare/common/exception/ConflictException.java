package com.petcare.common.exception;

/** Levée lors d'un conflit d'état (ex. email déjà utilisé) (→ HTTP 409). */
public class ConflictException extends RuntimeException {
    public ConflictException(String message) {
        super(message);
    }
}
