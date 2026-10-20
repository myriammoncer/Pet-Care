package com.petcare.pet.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.common.dto.PageResponse;
import com.petcare.common.security.SecurityUtils;
import com.petcare.pet.dto.PetRequest;
import com.petcare.pet.dto.PetResponse;
import com.petcare.pet.service.PetService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Gestion des profils animaux (/pets).
 */
@RestController
@RequestMapping("/pets")
@Tag(name = "Pets", description = "Profils des animaux de compagnie")
public class PetController {

    private final PetService petService;

    public PetController(PetService petService) {
        this.petService = petService;
    }

    @PostMapping
    @PreAuthorize("hasRole('PET_OWNER')")
    @Operation(summary = "Créer un profil animal")
    public ResponseEntity<ApiResponse<PetResponse>> create(@Valid @RequestBody PetRequest request) {
        PetResponse created = petService.create(SecurityUtils.currentUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(created));
    }

    @GetMapping
    @Operation(summary = "Lister les animaux (du propriétaire, ou tous pour l'admin)")
    public ApiResponse<PageResponse<PetResponse>> list(Pageable pageable) {
        var page = SecurityUtils.isAdmin()
                ? petService.listAll(pageable)
                : petService.listForOwner(SecurityUtils.currentUserId(), pageable);
        return ApiResponse.ok(PageResponse.from(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'un animal")
    public ApiResponse<PetResponse> getById(@PathVariable String id) {
        return ApiResponse.ok(petService.getById(id, SecurityUtils.currentUserId(), SecurityUtils.isAdmin()));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un animal")
    public ApiResponse<PetResponse> update(@PathVariable String id, @Valid @RequestBody PetRequest request) {
        return ApiResponse.ok(petService.update(id, SecurityUtils.currentUserId(), SecurityUtils.isAdmin(), request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un animal")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        petService.delete(id, SecurityUtils.currentUserId(), SecurityUtils.isAdmin());
        return ResponseEntity.noContent().build();
    }
}
