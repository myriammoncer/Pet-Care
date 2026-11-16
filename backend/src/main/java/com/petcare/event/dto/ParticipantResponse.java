package com.petcare.event.dto;

import java.time.Instant;

/** Participant d'un événement (vue admin), enrichi du nom de l'utilisateur et de l'animal. */
public record ParticipantResponse(
        String userId,
        String userName,
        String userEmail,
        String petId,
        String petName,
        Instant registeredAt
) {
}
