package com.petcare.medicalrecord.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.common.security.SecurityUtils;
import com.petcare.medicalrecord.domain.MedicalRecord;
import com.petcare.medicalrecord.dto.AllergyRequest;
import com.petcare.medicalrecord.dto.ConsultationRequest;
import com.petcare.medicalrecord.dto.MedicationRequest;
import com.petcare.medicalrecord.dto.VaccinationRequest;
import com.petcare.medicalrecord.service.MedicalRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Dossier médical d'un animal (/pets/{petId}/medical-record).
 * Lecture : propriétaire / vétérinaire / admin. Écriture : vétérinaire.
 */
@RestController
@RequestMapping("/pets/{petId}/medical-record")
@Tag(name = "Medical Record", description = "Historique médical, vaccinations, allergies, médicaments")
public class MedicalRecordController {

    private final MedicalRecordService service;

    public MedicalRecordController(MedicalRecordService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Dossier médical complet de l'animal")
    public ApiResponse<MedicalRecord> get(@PathVariable String petId) {
        return ApiResponse.ok(service.getByPet(petId));
    }

    @PostMapping("/consultations")
    @PreAuthorize("hasRole('VET')")
    @Operation(summary = "Ajouter une consultation (vétérinaire)")
    public ApiResponse<MedicalRecord> addConsultation(@PathVariable String petId,
                                                      @Valid @RequestBody ConsultationRequest request) {
        return ApiResponse.ok(service.addConsultation(petId, SecurityUtils.currentUserId(), request));
    }

    @PostMapping("/vaccinations")
    @PreAuthorize("hasRole('VET')")
    @Operation(summary = "Ajouter une vaccination (vétérinaire)")
    public ApiResponse<MedicalRecord> addVaccination(@PathVariable String petId,
                                                     @Valid @RequestBody VaccinationRequest request) {
        return ApiResponse.ok(service.addVaccination(petId, SecurityUtils.currentUserId(), request));
    }

    @PostMapping("/allergies")
    @PreAuthorize("hasRole('VET')")
    @Operation(summary = "Ajouter une allergie (vétérinaire)")
    public ApiResponse<MedicalRecord> addAllergy(@PathVariable String petId,
                                                 @Valid @RequestBody AllergyRequest request) {
        return ApiResponse.ok(service.addAllergy(petId, request));
    }

    @PostMapping("/medications")
    @PreAuthorize("hasRole('VET')")
    @Operation(summary = "Ajouter un médicament (vétérinaire)")
    public ApiResponse<MedicalRecord> addMedication(@PathVariable String petId,
                                                    @Valid @RequestBody MedicationRequest request) {
        return ApiResponse.ok(service.addMedication(petId, SecurityUtils.currentUserId(), request));
    }

    @DeleteMapping("/{section}/{itemId}")
    @PreAuthorize("hasRole('VET')")
    @Operation(summary = "Retirer un élément du dossier (vétérinaire)")
    public ResponseEntity<Void> removeItem(@PathVariable String petId,
                                           @PathVariable String section,
                                           @PathVariable String itemId) {
        service.removeItem(petId, section, itemId);
        return ResponseEntity.noContent().build();
    }
}
