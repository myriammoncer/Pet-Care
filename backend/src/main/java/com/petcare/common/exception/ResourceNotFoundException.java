package com.petcare.common.exception;

/** Levée lorsqu'une ressource demandée est introuvable (→ HTTP 404). */
public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String resource, String id) {
        super("%s not found: %s".formatted(resource, id));
    }

    public ResourceNotFoundException(String message) {
        super(message);
    }
}
