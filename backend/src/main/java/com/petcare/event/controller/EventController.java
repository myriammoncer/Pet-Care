package com.petcare.event.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.common.dto.PageResponse;
import com.petcare.common.security.SecurityUtils;
import com.petcare.event.domain.EventType;
import com.petcare.event.dto.EventRequest;
import com.petcare.event.dto.EventResponse;
import com.petcare.event.dto.ParticipantResponse;
import com.petcare.event.dto.RegisterRequest;
import com.petcare.event.service.EventService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

/**
 * Événements communautaires (/events). Lecture et inscription : authentifié.
 * Création / modification / suppression / gestion des participants : admin.
 */
@RestController
@RequestMapping("/events")
@Tag(name = "Events", description = "Promenades, concours, journées santé, adoption, ateliers")
public class EventController {

    private final EventService eventService;

    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @GetMapping
    @Operation(summary = "Lister les événements (à venir par défaut ; filtres type, from, to en ISO-8601)")
    public ApiResponse<PageResponse<EventResponse>> list(
            @RequestParam(required = false) EventType type,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant to,
            @PageableDefault(size = 20, sort = "startAt", direction = Sort.Direction.ASC) Pageable pageable) {
        return ApiResponse.ok(PageResponse.from(
                eventService.list(type, from, to, SecurityUtils.currentUserId(), pageable)));
    }

    @GetMapping("/me")
    @Operation(summary = "Mes inscriptions (événements à venir puis passés)")
    public ApiResponse<List<EventResponse>> myRegistrations() {
        return ApiResponse.ok(eventService.listMyRegistrations(SecurityUtils.currentUserId()));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'un événement")
    public ApiResponse<EventResponse> getById(@PathVariable String id) {
        return ApiResponse.ok(eventService.getById(id, SecurityUtils.currentUserId()));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Créer un événement (admin)")
    public ResponseEntity<ApiResponse<EventResponse>> create(@Valid @RequestBody EventRequest request) {
        EventResponse created = eventService.create(SecurityUtils.currentUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(created));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Modifier un événement (admin)")
    public ApiResponse<EventResponse> update(@PathVariable String id, @Valid @RequestBody EventRequest request) {
        return ApiResponse.ok(eventService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Supprimer un événement (admin)")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        eventService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/register")
    @Operation(summary = "S'inscrire à un événement avec un de ses animaux")
    public ApiResponse<EventResponse> register(@PathVariable String id, @Valid @RequestBody RegisterRequest request) {
        return ApiResponse.ok(eventService.register(id, SecurityUtils.currentUserId(), request.petId()));
    }

    @DeleteMapping("/{id}/register")
    @Operation(summary = "Se désinscrire d'un événement")
    public ApiResponse<EventResponse> unregister(@PathVariable String id) {
        return ApiResponse.ok(eventService.unregister(id, SecurityUtils.currentUserId()));
    }

    @GetMapping("/{id}/participants")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Liste des participants (admin)")
    public ApiResponse<List<ParticipantResponse>> participants(@PathVariable String id) {
        return ApiResponse.ok(eventService.listParticipants(id, SecurityUtils.currentUserId()));
    }

    @DeleteMapping("/{id}/participants/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Retirer un participant (admin)")
    public ApiResponse<EventResponse> removeParticipant(@PathVariable String id, @PathVariable String userId) {
        return ApiResponse.ok(eventService.removeParticipant(id, userId, SecurityUtils.currentUserId()));
    }
}
