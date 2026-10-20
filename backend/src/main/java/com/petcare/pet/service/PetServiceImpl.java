package com.petcare.pet.service;

import com.petcare.common.exception.ForbiddenException;
import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.pet.domain.Pet;
import com.petcare.pet.domain.PetStatus;
import com.petcare.pet.dto.PetRequest;
import com.petcare.pet.dto.PetResponse;
import com.petcare.pet.repository.PetRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
public class PetServiceImpl implements PetService {

    private final PetRepository petRepository;

    public PetServiceImpl(PetRepository petRepository) {
        this.petRepository = petRepository;
    }

    @Override
    public PetResponse create(String ownerId, PetRequest request) {
        Pet pet = Pet.builder()
                .ownerId(ownerId)
                .name(request.name())
                .species(request.species())
                .breed(request.breed())
                .birthDate(request.birthDate())
                .sex(request.sex())
                .weight(request.weight())
                .color(request.color())
                .photoUrl(request.photoUrl())
                .microchipNumber(request.microchipNumber())
                .status(request.status() == null ? PetStatus.HEALTHY : request.status())
                .build();
        return PetResponse.from(petRepository.save(pet));
    }

    @Override
    public PetResponse getById(String petId, String requesterId, boolean isAdmin) {
        return PetResponse.from(findAccessible(petId, requesterId, isAdmin));
    }

    @Override
    public Page<PetResponse> listForOwner(String ownerId, Pageable pageable) {
        return petRepository.findByOwnerId(ownerId, pageable).map(PetResponse::from);
    }

    @Override
    public Page<PetResponse> listAll(Pageable pageable) {
        return petRepository.findAll(pageable).map(PetResponse::from);
    }

    @Override
    public PetResponse update(String petId, String requesterId, boolean isAdmin, PetRequest request) {
        Pet pet = findAccessible(petId, requesterId, isAdmin);
        pet.setName(request.name());
        pet.setSpecies(request.species());
        pet.setBreed(request.breed());
        pet.setBirthDate(request.birthDate());
        pet.setSex(request.sex());
        pet.setWeight(request.weight());
        pet.setColor(request.color());
        pet.setPhotoUrl(request.photoUrl());
        pet.setMicrochipNumber(request.microchipNumber());
        if (request.status() != null) {
            pet.setStatus(request.status());
        }
        return PetResponse.from(petRepository.save(pet));
    }

    @Override
    public void delete(String petId, String requesterId, boolean isAdmin) {
        Pet pet = findAccessible(petId, requesterId, isAdmin);
        petRepository.delete(pet);
    }

    @Override
    public boolean exists(String petId) {
        return petRepository.existsById(petId);
    }

    /** Charge l'animal et vérifie que le demandeur est le propriétaire ou un admin. */
    private Pet findAccessible(String petId, String requesterId, boolean isAdmin) {
        Pet pet = petRepository.findById(petId)
                .orElseThrow(() -> new ResourceNotFoundException("Pet", petId));
        if (!isAdmin && !pet.getOwnerId().equals(requesterId)) {
            throw new ForbiddenException("Access denied to pet " + petId);
        }
        return pet;
    }
}
