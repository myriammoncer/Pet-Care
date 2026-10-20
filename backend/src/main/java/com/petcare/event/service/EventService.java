package com.petcare.event.service;

import com.petcare.event.domain.EventType;
import com.petcare.event.dto.EventRequest;
import com.petcare.event.dto.EventResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/**
 * Gestion des événements. La création/modification est réservée à l'admin ;
 * l'inscription est ouverte à tout utilisateur authentifié.
 */
public interface EventService {

    Page<EventResponse> listUpcoming(EventType type, Pageable pageable);

    EventResponse getById(String id);

    EventResponse create(String adminId, EventRequest request);

    EventResponse update(String id, EventRequest request);

    void delete(String id);

    EventResponse register(String id, String userId, String petId);

    EventResponse unregister(String id, String userId);
}
