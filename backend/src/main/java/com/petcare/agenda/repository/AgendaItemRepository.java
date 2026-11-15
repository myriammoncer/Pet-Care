package com.petcare.agenda.repository;

import com.petcare.agenda.domain.AgendaItem;
import com.petcare.agenda.domain.AgendaItemStatus;
import com.petcare.agenda.domain.AgendaItemType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.time.Instant;
import java.util.List;

public interface AgendaItemRepository extends MongoRepository<AgendaItem, String>, AgendaItemRepositoryCustom {

    Page<AgendaItem> findByOwnerId(String ownerId, Pageable pageable);

    Page<AgendaItem> findByOwnerIdAndType(String ownerId, AgendaItemType type, Pageable pageable);

    Page<AgendaItem> findByPetId(String petId, Pageable pageable);

    List<AgendaItem> findByStatusAndScheduledAtBefore(AgendaItemStatus status, Instant time);
}