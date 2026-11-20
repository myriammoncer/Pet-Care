package com.petcare.event.service;

import com.petcare.common.exception.ConflictException;
import com.petcare.common.exception.ForbiddenException;
import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.event.domain.Event;
import com.petcare.event.domain.Event.Participant;
import com.petcare.event.domain.EventType;
import com.petcare.event.dto.EventRequest;
import com.petcare.event.dto.EventResponse;
import com.petcare.event.dto.ParticipantResponse;
import com.petcare.event.repository.EventRepository;
import com.petcare.pet.service.PetService;
import com.petcare.user.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** Règles métier du module Événements (sans base de données : repository mocké). */
@ExtendWith(MockitoExtension.class)
class EventServiceImplTest {

    private static final Instant NOW = Instant.parse("2026-11-16T10:00:00Z");
    private static final String EVENT_ID = "evt1";
    private static final String USER_ID = "user1";
    private static final String PET_ID = "pet1";

    @Mock
    private EventRepository repository;
    @Mock
    private PetService petService;
    @Mock
    private UserService userService;

    private EventServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new EventServiceImpl(repository, petService, userService, Clock.fixed(NOW, ZoneOffset.UTC));
    }

    private static Event event(Instant startAt, int capacity, Participant... participants) {
        Event e = Event.builder()
                .title("Promenade").type(EventType.GROUP_WALK).location("Parc")
                .startAt(startAt).capacity(capacity)
                .participants(new ArrayList<>(List.of(participants)))
                .build();
        e.setId(EVENT_ID);
        return e;
    }

    private static Participant participant(String userId) {
        return Participant.builder().userId(userId).petId("p-" + userId).registeredAt(NOW).build();
    }

    private static EventRequest request(Instant startAt, Instant endAt, int capacity) {
        return new EventRequest("Promenade", "desc", EventType.GROUP_WALK, startAt, endAt, "Parc", capacity);
    }

    // ─── Inscription ──────────────────────────────────────────────────────

    @Test
    void register_ok_addsParticipantAtomically() {
        Event before = event(NOW.plus(Duration.ofDays(2)), 10);
        Event after = event(NOW.plus(Duration.ofDays(2)), 10, Participant.builder()
                .userId(USER_ID).petId(PET_ID).registeredAt(NOW).build());
        when(repository.findById(EVENT_ID)).thenReturn(Optional.of(before), Optional.of(after));
        when(repository.addParticipant(eq(EVENT_ID), eq(10), any())).thenReturn(true);

        EventResponse res = service.register(EVENT_ID, USER_ID, PET_ID);

        ArgumentCaptor<Participant> captor = ArgumentCaptor.forClass(Participant.class);
        verify(repository).addParticipant(eq(EVENT_ID), eq(10), captor.capture());
        assertThat(captor.getValue().getUserId()).isEqualTo(USER_ID);
        assertThat(captor.getValue().getPetId()).isEqualTo(PET_ID);
        assertThat(captor.getValue().getRegisteredAt()).isEqualTo(NOW);
        verify(petService).getById(PET_ID, USER_ID, false);
        assertThat(res.registered()).isTrue();
        assertThat(res.myPetId()).isEqualTo(PET_ID);
        assertThat(res.registeredCount()).isEqualTo(1);
    }

    @Test
    void register_withSomeoneElsesPet_isForbidden() {
        when(repository.findById(EVENT_ID)).thenReturn(Optional.of(event(NOW.plus(Duration.ofDays(1)), 10)));
        when(petService.getById(PET_ID, USER_ID, false)).thenThrow(new ForbiddenException("Access denied"));

        assertThatThrownBy(() -> service.register(EVENT_ID, USER_ID, PET_ID))
                .isInstanceOf(ForbiddenException.class);
        verify(repository, never()).addParticipant(anyString(), anyInt(), any());
    }

    @Test
    void register_twice_isConflict() {
        when(repository.findById(EVENT_ID))
                .thenReturn(Optional.of(event(NOW.plus(Duration.ofDays(1)), 10, participant(USER_ID))));

        assertThatThrownBy(() -> service.register(EVENT_ID, USER_ID, PET_ID))
                .isInstanceOf(ConflictException.class)
                .hasMessageContaining("déjà inscrit");
    }

    @Test
    void register_whenFull_isConflict() {
        when(repository.findById(EVENT_ID))
                .thenReturn(Optional.of(event(NOW.plus(Duration.ofDays(1)), 1, participant("other"))));

        assertThatThrownBy(() -> service.register(EVENT_ID, USER_ID, PET_ID))
                .isInstanceOf(ConflictException.class)
                .hasMessageContaining("complet");
    }

    @Test
    void register_afterStart_isConflict() {
        when(repository.findById(EVENT_ID)).thenReturn(Optional.of(event(NOW.minus(Duration.ofHours(1)), 10)));

        assertThatThrownBy(() -> service.register(EVENT_ID, USER_ID, PET_ID))
                .isInstanceOf(ConflictException.class)
                .hasMessageContaining("closes");
    }

    @Test
    void register_lostRaceForLastSpot_isConflict() {
        Event open = event(NOW.plus(Duration.ofDays(1)), 1);
        Event fullNow = event(NOW.plus(Duration.ofDays(1)), 1, participant("other"));
        when(repository.findById(EVENT_ID)).thenReturn(Optional.of(open), Optional.of(fullNow));
        when(repository.addParticipant(eq(EVENT_ID), eq(1), any())).thenReturn(false);

        assertThatThrownBy(() -> service.register(EVENT_ID, USER_ID, PET_ID))
                .isInstanceOf(ConflictException.class)
                .hasMessageContaining("complet");
    }

    @Test
    void register_unknownEvent_isNotFound() {
        when(repository.findById(EVENT_ID)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.register(EVENT_ID, USER_ID, PET_ID))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // ─── Désinscription ───────────────────────────────────────────────────

    @Test
    void unregister_ok() {
        Event registered = event(NOW.plus(Duration.ofDays(1)), 10, participant(USER_ID));
        Event after = event(NOW.plus(Duration.ofDays(1)), 10);
        when(repository.findById(EVENT_ID)).thenReturn(Optional.of(registered), Optional.of(after));

        EventResponse res = service.unregister(EVENT_ID, USER_ID);

        verify(repository).removeParticipant(EVENT_ID, USER_ID);
        assertThat(res.registered()).isFalse();
    }

    @Test
    void unregister_whenNotRegistered_isConflict() {
        when(repository.findById(EVENT_ID)).thenReturn(Optional.of(event(NOW.plus(Duration.ofDays(1)), 10)));

        assertThatThrownBy(() -> service.unregister(EVENT_ID, USER_ID))
                .isInstanceOf(ConflictException.class);
        verify(repository, never()).removeParticipant(anyString(), anyString());
    }

    @Test
    void unregister_afterStart_isConflict() {
        when(repository.findById(EVENT_ID))
                .thenReturn(Optional.of(event(NOW.minus(Duration.ofMinutes(5)), 10, participant(USER_ID))));

        assertThatThrownBy(() -> service.unregister(EVENT_ID, USER_ID))
                .isInstanceOf(ConflictException.class);
    }

    // ─── Création / modification ──────────────────────────────────────────

    @Test
    void create_inThePast_isConflict() {
        assertThatThrownBy(() -> service.create("admin", request(NOW.minus(Duration.ofDays(1)), null, 10)))
                .isInstanceOf(ConflictException.class);
        verify(repository, never()).save(any());
    }

    @Test
    void create_ok_setsOrganizer() {
        when(repository.save(any(Event.class))).thenAnswer(inv -> inv.getArgument(0));

        EventResponse res = service.create("admin", request(NOW.plus(Duration.ofDays(3)), null, 15));

        assertThat(res.createdBy()).isEqualTo("admin");
        assertThat(res.capacity()).isEqualTo(15);
        assertThat(res.registeredCount()).isZero();
    }

    @Test
    void update_capacityBelowRegistered_isConflict() {
        when(repository.findById(EVENT_ID)).thenReturn(Optional.of(
                event(NOW.plus(Duration.ofDays(1)), 10, participant("a"), participant("b"), participant("c"))));

        assertThatThrownBy(() -> service.update(EVENT_ID, request(NOW.plus(Duration.ofDays(1)), null, 2)))
                .isInstanceOf(ConflictException.class);
        verify(repository, never()).save(any());
    }

    @Test
    void request_endBeforeStart_isInvalid() {
        Instant start = NOW.plus(Duration.ofDays(1));
        assertThat(request(start, start.minus(Duration.ofHours(1)), 5).isEndAfterStart()).isFalse();
        assertThat(request(start, start.plus(Duration.ofHours(1)), 5).isEndAfterStart()).isTrue();
        assertThat(request(start, null, 5).isEndAfterStart()).isTrue();
    }

    // ─── Lecture ──────────────────────────────────────────────────────────

    @Test
    void myRegistrations_upcomingFirstThenPast() {
        Event past = event(NOW.minus(Duration.ofDays(2)), 10, participant(USER_ID));
        past.setId("past");
        Event soon = event(NOW.plus(Duration.ofDays(1)), 10, participant(USER_ID));
        soon.setId("soon");
        Event later = event(NOW.plus(Duration.ofDays(5)), 10, participant(USER_ID));
        later.setId("later");
        when(repository.findRegisteredBy(eq(USER_ID), any())).thenReturn(List.of(past, soon, later));

        List<EventResponse> res = service.listMyRegistrations(USER_ID);

        assertThat(res).extracting(EventResponse::id).containsExactly("soon", "later", "past");
        assertThat(res).allMatch(EventResponse::registered);
    }

    @Test
    void participants_toleratesDeletedPet() {
        when(repository.findById(EVENT_ID))
                .thenReturn(Optional.of(event(NOW.plus(Duration.ofDays(1)), 10, participant(USER_ID))));
        when(petService.getById(anyString(), eq("admin"), eq(true)))
                .thenThrow(new ResourceNotFoundException("Pet", "p-" + USER_ID));
        when(userService.getById(USER_ID)).thenThrow(new ResourceNotFoundException("User", USER_ID));

        List<ParticipantResponse> res = service.listParticipants(EVENT_ID, "admin");

        assertThat(res).hasSize(1);
        assertThat(res.get(0).userId()).isEqualTo(USER_ID);
        assertThat(res.get(0).petName()).isNull();
    }
}
