package com.petcare.agenda.service;

import com.petcare.agenda.domain.AgendaItemStatus;
import com.petcare.agenda.domain.AgendaItemType;
import com.petcare.agenda.dto.AgendaItemRequest;
import com.petcare.agenda.dto.AgendaItemResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.Instant;

/**
 * Gestion des éléments d'agenda (rappels / rendez-vous). Chaque élément
 * appartient au propriétaire courant ; l'accès est vérifié par ownership.
 */
public interface AgendaService {

    AgendaItemResponse create(String ownerId, AgendaItemRequest request);

    Page<AgendaItemResponse> list(String ownerId, String petId, AgendaItemType type,
                                  Instant from, Instant to, Pageable pageable);

    AgendaItemResponse getById(String id, String ownerId);

    AgendaItemResponse update(String id, String ownerId, AgendaItemRequest request);

    AgendaItemResponse updateStatus(String id, String ownerId, AgendaItemStatus status);

    void delete(String id, String ownerId);
}