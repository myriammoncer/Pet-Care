package com.petcare.agenda.repository;

import com.petcare.agenda.domain.AgendaItem;
import com.petcare.agenda.domain.AgendaItemType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface AgendaItemRepository extends MongoRepository<AgendaItem, String> {

    Page<AgendaItem> findByOwnerId(String ownerId, Pageable pageable);

    Page<AgendaItem> findByOwnerIdAndType(String ownerId, AgendaItemType type, Pageable pageable);

    Page<AgendaItem> findByPetId(String petId, Pageable pageable);
}
