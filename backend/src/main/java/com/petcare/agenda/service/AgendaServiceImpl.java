package com.petcare.agenda.service;

import com.petcare.agenda.domain.AgendaItem;
import com.petcare.agenda.domain.AgendaItemStatus;
import com.petcare.agenda.domain.AgendaItemType;
import com.petcare.agenda.dto.AgendaItemRequest;
import com.petcare.agenda.dto.AgendaItemResponse;
import com.petcare.agenda.repository.AgendaItemRepository;
import com.petcare.common.exception.ForbiddenException;
import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.pet.service.PetService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class AgendaServiceImpl implements AgendaService {

    private final AgendaItemRepository repository;
    private final PetService petService;

    public AgendaServiceImpl(AgendaItemRepository repository, PetService petService) {
        this.repository = repository;
        this.petService = petService;
    }

    @Override
    public AgendaItemResponse create(String ownerId, AgendaItemRequest r) {
        if (!petService.exists(r.petId())) {
            throw new ResourceNotFoundException("Pet", r.petId());
        }
        AgendaItem item = AgendaItem.builder()
                .ownerId(ownerId).petId(r.petId()).type(r.type()).title(r.title())
                .notes(r.notes()).scheduledAt(r.scheduledAt()).reminderAt(r.reminderAt())
                .status(AgendaItemStatus.SCHEDULED).recurrence(r.recurrence())
                .build();
        return AgendaItemResponse.from(repository.save(item));
    }

    @Override
    public Page<AgendaItemResponse> list(String ownerId, String petId, AgendaItemType type,
                                         Instant from, Instant to, Pageable pageable) {
        return repository.search(ownerId, petId, type, from, to, pageable)
                .map(AgendaItemResponse::from);
    }

    @Override
    public AgendaItemResponse getById(String id, String ownerId) {
        return AgendaItemResponse.from(findOwned(id, ownerId));
    }

    @Override
    public AgendaItemResponse update(String id, String ownerId, AgendaItemRequest r) {
        AgendaItem item = findOwned(id, ownerId);
        item.setType(r.type());
        item.setTitle(r.title());
        item.setNotes(r.notes());
        item.setScheduledAt(r.scheduledAt());
        item.setReminderAt(r.reminderAt());
        item.setRecurrence(r.recurrence());
        return AgendaItemResponse.from(repository.save(item));
    }

    @Override
    public AgendaItemResponse updateStatus(String id, String ownerId, AgendaItemStatus status) {
        AgendaItem item = findOwned(id, ownerId);
        item.setStatus(status);
        AgendaItem saved = repository.save(item);

        // Récurrence : un rappel récurrent marqué « fait » planifie automatiquement le suivant.
        if (status == AgendaItemStatus.DONE && item.getRecurrence() != null) {
            createNextOccurrence(item);
        }
        return AgendaItemResponse.from(saved);
    }

    @Override
    public void delete(String id, String ownerId) {
        repository.delete(findOwned(id, ownerId));
    }

    private AgendaItem findOwned(String id, String ownerId) {
        AgendaItem item = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("AgendaItem", id));
        if (!item.getOwnerId().equals(ownerId)) {
            throw new ForbiddenException("Access denied to agenda item " + id);
        }
        return item;
    }

    /** Crée la prochaine occurrence d'un rappel récurrent terminé. */
    private void createNextOccurrence(AgendaItem done) {
        Instant nextScheduledAt = done.getRecurrence().next(done.getScheduledAt());
        Instant nextReminderAt = (done.getReminderAt() == null)
                ? null
                : done.getRecurrence().next(done.getReminderAt());

        AgendaItem next = AgendaItem.builder()
                .ownerId(done.getOwnerId())
                .petId(done.getPetId())
                .type(done.getType())
                .title(done.getTitle())
                .notes(done.getNotes())
                .scheduledAt(nextScheduledAt)
                .reminderAt(nextReminderAt)
                .status(AgendaItemStatus.SCHEDULED)
                .recurrence(done.getRecurrence())
                .build();
        repository.save(next);
    }
}