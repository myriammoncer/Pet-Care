package com.petcare.event.service;

import com.petcare.common.exception.ConflictException;
import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.event.domain.Event;
import com.petcare.event.domain.Event.Participant;
import com.petcare.event.domain.EventType;
import com.petcare.event.dto.EventRequest;
import com.petcare.event.dto.EventResponse;
import com.petcare.event.dto.ParticipantResponse;
import com.petcare.event.repository.EventRepository;
import com.petcare.pet.dto.PetResponse;
import com.petcare.pet.service.PetService;
import com.petcare.user.dto.UserResponse;
import com.petcare.user.service.UserService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Règles métier du module Événements :
 * <ul>
 *   <li>on ne s'inscrit qu'avec <b>un de ses animaux</b> (contrôle via {@link PetService}) ;</li>
 *   <li>une seule inscription par utilisateur et par événement ;</li>
 *   <li>capacité respectée, y compris en cas d'inscriptions simultanées (écriture atomique) ;</li>
 *   <li>plus d'inscription / désinscription une fois l'événement commencé ;</li>
 *   <li>un événement se crée dans le futur et sa capacité ne descend pas sous le nombre d'inscrits.</li>
 * </ul>
 * Les autres modules sont utilisés uniquement via leurs interfaces de service.
 */
@Service
public class EventServiceImpl implements EventService {

    private final EventRepository repository;
    private final PetService petService;
    private final UserService userService;
    private final Clock clock;

    @Autowired
    public EventServiceImpl(EventRepository repository, PetService petService, UserService userService) {
        this(repository, petService, userService, Clock.systemUTC());
    }

    /** Constructeur avec horloge injectable (tests). */
    EventServiceImpl(EventRepository repository, PetService petService, UserService userService, Clock clock) {
        this.repository = repository;
        this.petService = petService;
        this.userService = userService;
        this.clock = clock;
    }

    @Override
    public Page<EventResponse> list(EventType type, Instant from, Instant to, String currentUserId,
                                    Pageable pageable) {
        Instant effectiveFrom = (from != null) ? from : now();
        return repository.search(type, effectiveFrom, to, pageable)
                .map(e -> EventResponse.from(e, currentUserId));
    }

    @Override
    public List<EventResponse> listMyRegistrations(String userId) {
        Instant now = now();
        List<Event> events = new ArrayList<>(repository.findRegisteredBy(userId, Sort.by("startAt")));
        // À venir d'abord (plus proche en premier), puis passés (plus récent en premier).
        events.sort(Comparator
                .comparing((Event e) -> e.hasStarted(now))
                .thenComparing(e -> e.hasStarted(now)
                        ? -e.getStartAt().toEpochMilli()
                        : e.getStartAt().toEpochMilli()));
        return events.stream().map(e -> EventResponse.from(e, userId)).toList();
    }

    @Override
    public EventResponse getById(String id, String currentUserId) {
        return EventResponse.from(findOrThrow(id), currentUserId);
    }

    @Override
    public EventResponse create(String adminId, EventRequest r) {
        if (!r.startAt().isAfter(now())) {
            throw new ConflictException("La date de début doit être dans le futur");
        }
        Event event = Event.builder()
                .title(r.title().trim()).description(r.description()).type(r.type())
                .startAt(r.startAt()).endAt(r.endAt()).location(r.location().trim())
                .capacity(r.capacity()).createdBy(adminId)
                .build();
        return EventResponse.from(repository.save(event), adminId);
    }

    @Override
    public EventResponse update(String id, EventRequest r) {
        Event event = findOrThrow(id);
        if (r.capacity() < event.getParticipants().size()) {
            throw new ConflictException("Capacité inférieure au nombre d'inscrits ("
                    + event.getParticipants().size() + ")");
        }
        event.setTitle(r.title().trim());
        event.setDescription(r.description());
        event.setType(r.type());
        event.setStartAt(r.startAt());
        event.setEndAt(r.endAt());
        event.setLocation(r.location().trim());
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
        if (event.hasStarted(now())) {
            throw new ConflictException("Les inscriptions sont closes : l'événement a commencé");
        }
        if (event.isRegistered(userId)) {
            throw new ConflictException("Vous êtes déjà inscrit à cet événement");
        }
        if (event.isFull()) {
            throw new ConflictException("L'événement est complet");
        }
        // On s'inscrit avec SON animal (même un admin) : lève ResourceNotFound / Forbidden sinon.
        petService.getById(petId, userId, false);

        Participant participant = Participant.builder()
                .userId(userId).petId(petId).registeredAt(now()).build();
        if (!repository.addParticipant(id, event.getCapacity(), participant)) {
            // Course perdue face à une autre inscription (ou capacité modifiée entre-temps).
            Event fresh = findOrThrow(id);
            if (fresh.isRegistered(userId)) {
                throw new ConflictException("Vous êtes déjà inscrit à cet événement");
            }
            throw new ConflictException("L'événement est complet");
        }
        return EventResponse.from(findOrThrow(id), userId);
    }

    @Override
    public EventResponse unregister(String id, String userId) {
        Event event = findOrThrow(id);
        if (!event.isRegistered(userId)) {
            throw new ConflictException("Vous n'êtes pas inscrit à cet événement");
        }
        if (event.hasStarted(now())) {
            throw new ConflictException("Impossible de se désinscrire : l'événement a commencé");
        }
        repository.removeParticipant(id, userId);
        return EventResponse.from(findOrThrow(id), userId);
    }

    @Override
    public List<ParticipantResponse> listParticipants(String id, String adminId) {
        Event event = findOrThrow(id);
        return event.getParticipants().stream()
                .sorted(Comparator.comparing(Participant::getRegisteredAt,
                        Comparator.nullsLast(Comparator.naturalOrder())))
                .map(p -> toParticipantResponse(p, adminId))
                .toList();
    }

    @Override
    public EventResponse removeParticipant(String id, String userId, String adminId) {
        Event event = findOrThrow(id);
        if (!event.isRegistered(userId)) {
            throw new ResourceNotFoundException("Participant", userId);
        }
        repository.removeParticipant(id, userId);
        return EventResponse.from(findOrThrow(id), adminId);
    }

    /** Enrichit un participant avec les noms ; tolère un compte ou un animal supprimé. */
    private ParticipantResponse toParticipantResponse(Participant p, String adminId) {
        String userName = null;
        String userEmail = null;
        String petName = null;
        try {
            UserResponse user = userService.getById(p.getUserId());
            userName = String.join(" ",
                    user.firstName() == null ? "" : user.firstName(),
                    user.lastName() == null ? "" : user.lastName()).trim();
            userEmail = user.email();
        } catch (ResourceNotFoundException ignored) {
            // compte supprimé : on garde l'identifiant seul
        }
        try {
            PetResponse pet = petService.getById(p.getPetId(), adminId, true);
            petName = pet.name();
        } catch (ResourceNotFoundException ignored) {
            // animal supprimé : on garde l'identifiant seul
        }
        return new ParticipantResponse(p.getUserId(), userName, userEmail, p.getPetId(), petName,
                p.getRegisteredAt());
    }

    private Instant now() {
        return Instant.now(clock);
    }

    private Event findOrThrow(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Event", id));
    }
}
