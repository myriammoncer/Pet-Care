package com.petcare.event.service;

import com.petcare.common.exception.ConflictException;
import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.event.domain.Event;
import com.petcare.event.domain.Event.Participant;
import com.petcare.event.domain.EventType;
import com.petcare.event.dto.EventRequest;
import com.petcare.event.dto.EventResponse;
import com.petcare.event.repository.EventRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class EventServiceImpl implements EventService {

    private final EventRepository repository;

    public EventServiceImpl(EventRepository repository) {
        this.repository = repository;
    }

    @Override
    public Page<EventResponse> listUpcoming(EventType type, Pageable pageable) {
        Instant now = Instant.now();
        Page<Event> page = (type == null)
                ? repository.findByStartAtAfter(now, pageable)
                : repository.findByTypeAndStartAtAfter(type, now, pageable);
        return page.map(EventResponse::from);
    }

    @Override
    public EventResponse getById(String id) {
        return EventResponse.from(findOrThrow(id));
    }

    @Override
    public EventResponse create(String adminId, EventRequest r) {
        Event event = Event.builder()
                .title(r.title()).description(r.description()).type(r.type())
                .startAt(r.startAt()).endAt(r.endAt()).location(r.location())
                .capacity(r.capacity()).createdBy(adminId)
                .build();
        return EventResponse.from(repository.save(event));
    }

    @Override
    public EventResponse update(String id, EventRequest r) {
        Event event = findOrThrow(id);
        event.setTitle(r.title());
        event.setDescription(r.description());
        event.setType(r.type());
        event.setStartAt(r.startAt());
        event.setEndAt(r.endAt());
        event.setLocation(r.location());
        event.setCapacity(r.capacity());
        return EventResponse.from(repository.save(event));
    }

    @Override
    public void delete(String id) {
        repository.delete(findOrThrow(id));
    }

    @Override
    public EventResponse register(String id, String userId, String petId) {
        Event event = findOrThrow(id);
        boolean already = event.getParticipants().stream()
                .anyMatch(p -> p.getUserId().equals(userId));
        if (already) {
            throw new ConflictException("Already registered to event " + id);
        }
        if (event.isFull()) {
            throw new ConflictException("Event is full: " + id);
        }
        event.getParticipants().add(Participant.builder()
                .userId(userId).petId(petId).registeredAt(Instant.now()).build());
        return EventResponse.from(repository.save(event));
    }

    @Override
    public EventResponse unregister(String id, String userId) {
        Event event = findOrThrow(id);
        event.getParticipants().removeIf(p -> p.getUserId().equals(userId));
        return EventResponse.from(repository.save(event));
    }

    private Event findOrThrow(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Event", id));
    }
}
