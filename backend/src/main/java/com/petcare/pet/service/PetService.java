package com.petcare.pet.service;

import com.petcare.pet.dto.PetRequest;
import com.petcare.pet.dto.PetResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/**
 * Gestion des profils animaux. Les règles d'ownership (un propriétaire n'accède
 * qu'à ses animaux, sauf admin) sont appliquées dans l'implémentation.
 */
public interface PetService {

    PetResponse create(String ownerId, PetRequest request);

    PetResponse getById(String petId, String requesterId, boolean isAdmin);

    Page<PetResponse> listForOwner(String ownerId, Pageable pageable);

    Page<PetResponse> listAll(Pageable pageable);

    PetResponse update(String petId, String requesterId, boolean isAdmin, PetRequest request);

    void delete(String petId, String requesterId, boolean isAdmin);

    /** Vérifie l'existence d'un animal (utilisé par d'autres modules). */
    boolean exists(String petId);
}
