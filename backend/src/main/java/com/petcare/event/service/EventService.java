package com.petcare.event.service;

import com.petcare.event.domain.EventType;
import com.petcare.event.dto.EventRequest;
import com.petcare.event.dto.EventResponse;
import com.petcare.event.dto.ParticipantResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.Instant;
import java.util.List;

/**
 * Gestion des événements. La création/modification est réservée à l'admin ;
 * l'inscription est ouverte à tout utilisateur authentifié, avec un de ses animaux.
 */
public interface EventService {

    /**
     * Liste des événements. Par défaut (sans {@code from}), seuls les événements
     * à venir sont renvoyés.
     */
    Page<EventResponse> list(EventType type, Instant from, Instant to, String currentUserId, Pageable pageable);

    /** Événements auxquels l'utilisateur est inscrit (à venir puis passés, triés par date). */
    List<EventResponse> listMyRegistrations(String userId);

    EventResponse getById(String id, String currentUserId);

    EventResponse create(String adminId, EventRequest request);

    EventResponse update(String id, EventRequest request);

    void delete(String id);

    EventResponse register(String id, String userId, String petId);

    EventResponse unregister(String id, String userId);

    /** Liste nominative des participants (admin). */
    List<ParticipantResponse> listParticipants(String id, String adminId);

    /** Retire un participant (admin). */
    EventResponse removeParticipant(String id, String userId, String adminId);
}
