package com.petcare.agenda.repository;

import com.petcare.agenda.domain.AgendaItem;
import com.petcare.agenda.domain.AgendaItemType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.Instant;

/** Requête de recherche dynamique (filtres optionnels) pour l'agenda. */
public interface AgendaItemRepositoryCustom {

    Page<AgendaItem> search(String ownerId, String petId, AgendaItemType type,
                            Instant from, Instant to, Pageable pageable);
}