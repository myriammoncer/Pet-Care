package com.petcare.medicalrecord.repository;

import com.petcare.medicalrecord.domain.MedicalRecord;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface MedicalRecordRepository extends MongoRepository<MedicalRecord, String> {

    Optional<MedicalRecord> findByPetId(String petId);
}
