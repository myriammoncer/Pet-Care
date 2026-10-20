package com.petcare.agenda.controller;

import com.petcare.agenda.domain.AgendaItemType;
import com.petcare.agenda.dto.AgendaItemRequest;
import com.petcare.agenda.dto.AgendaItemResponse;
import com.petcare.agenda.dto.UpdateAgendaStatusRequest;
import com.petcare.agenda.service.AgendaService;
import com.petcare.common.dto.ApiResponse;
import com.petcare.common.dto.PageResponse;
import com.petcare.common.security.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Agenda et rappels de soins (/agenda). Réservé aux propriétaires.
 */
@RestController
@RequestMapping("/agenda")
@PreAuthorize("hasRole('PET_OWNER')")
@Tag(name = "Agenda", description = "Rappels : vaccination, vermifuge, médicaments, rendez-vous, toilettage")
public class AgendaController {

    private final AgendaService agendaService;

    public AgendaController(AgendaService agendaService) {
        this.agendaService = agendaService;
    }

    @PostMapping
    @Operation(summary = "Créer un rappel / rendez-vous")
    public ResponseEntity<ApiResponse<AgendaItemResponse>> create(@Valid @RequestBody AgendaItemRequest request) {
        AgendaItemResponse created = agendaService.create(SecurityUtils.currentUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(created));
    }

    @GetMapping
    @Operation(summary = "Lister les éléments d'agenda (filtre optionnel par type)")
    public ApiResponse<PageResponse<AgendaItemResponse>> list(
            @RequestParam(required = false) AgendaItemType type, Pageable pageable) {
        return ApiResponse.ok(PageResponse.from(
                agendaService.list(SecurityUtils.currentUserId(), type, pageable)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'un élément d'agenda")
    public ApiResponse<AgendaItemResponse> getById(@PathVariable String id) {
        return ApiResponse.ok(agendaService.getById(id, SecurityUtils.currentUserId()));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un élément d'agenda")
    public ApiResponse<AgendaItemResponse> update(@PathVariable String id,
                                                  @Valid @RequestBody AgendaItemRequest request) {
        return ApiResponse.ok(agendaService.update(id, SecurityUtils.currentUserId(), request));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Changer le statut (DONE, CANCELLED…)")
    public ApiResponse<AgendaItemResponse> updateStatus(@PathVariable String id,
                                                        @Valid @RequestBody UpdateAgendaStatusRequest request) {
        return ApiResponse.ok(agendaService.updateStatus(id, SecurityUtils.currentUserId(), request.status()));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un élément d'agenda")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        agendaService.delete(id, SecurityUtils.currentUserId());
        return ResponseEntity.noContent().build();
    }
}
