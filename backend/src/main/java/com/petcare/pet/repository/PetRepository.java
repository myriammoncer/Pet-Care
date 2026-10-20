package com.petcare.pet.repository;

import com.petcare.pet.domain.Pet;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface PetRepository extends MongoRepository<Pet, String> {

    Page<Pet> findByOwnerId(String ownerId, Pageable pageable);
}
