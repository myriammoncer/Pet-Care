package com.petcare.medicalrecord.service;

import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.medicalrecord.domain.MedicalRecord;
import com.petcare.medicalrecord.domain.MedicalRecord.Allergy;
import com.petcare.medicalrecord.domain.MedicalRecord.Consultation;
import com.petcare.medicalrecord.domain.MedicalRecord.Medication;
import com.petcare.medicalrecord.domain.MedicalRecord.Vaccination;
import com.petcare.medicalrecord.dto.AllergyRequest;
import com.petcare.medicalrecord.dto.ConsultationRequest;
import com.petcare.medicalrecord.dto.MedicationRequest;
import com.petcare.medicalrecord.dto.VaccinationRequest;
import com.petcare.medicalrecord.repository.MedicalRecordRepository;
import com.petcare.pet.service.PetService;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class MedicalRecordServiceImpl implements MedicalRecordService {

    private final MedicalRecordRepository repository;
    private final PetService petService;

    public MedicalRecordServiceImpl(MedicalRecordRepository repository, PetService petService) {
        this.repository = repository;
        this.petService = petService;
    }

    @Override
    public MedicalRecord getByPet(String petId) {
        return repository.findByPetId(petId).orElseGet(() -> createEmpty(petId));
    }

    @Override
    public MedicalRecord addConsultation(String petId, String vetId, ConsultationRequest r) {
        MedicalRecord record = getByPet(petId);
        record.getConsultations().add(Consultation.builder()
                .id(newId()).date(r.date()).reason(r.reason())
                .diagnosis(r.diagnosis()).notes(r.notes()).vetId(vetId).build());
        return repository.save(record);
    }

    @Override
    public MedicalRecord addVaccination(String petId, String vetId, VaccinationRequest r) {
        MedicalRecord record = getByPet(petId);
        record.getVaccinations().add(Vaccination.builder()
                .id(newId()).vaccineName(r.vaccineName()).date(r.date())
                .nextDueDate(r.nextDueDate()).vetId(vetId).build());
        return repository.save(record);
    }

    @Override
    public MedicalRecord addAllergy(String petId, AllergyRequest r) {
        MedicalRecord record = getByPet(petId);
        record.getAllergies().add(Allergy.builder()
                .id(newId()).substance(r.substance()).severity(r.severity())
                .reaction(r.reaction()).notes(r.notes()).build());
        return repository.save(record);
    }

    @Override
    public MedicalRecord addMedication(String petId, String vetId, MedicationRequest r) {
        MedicalRecord record = getByPet(petId);
        record.getMedications().add(Medication.builder()
                .id(newId()).name(r.name()).dosage(r.dosage()).frequency(r.frequency())
                .startDate(r.startDate()).endDate(r.endDate()).prescribedBy(vetId).build());
        return repository.save(record);
    }

    @Override
    public MedicalRecord removeItem(String petId, String section, String itemId) {
        MedicalRecord record = repository.findByPetId(petId)
                .orElseThrow(() -> new ResourceNotFoundException("MedicalRecord for pet", petId));
        switch (section) {
            case "consultations" -> record.getConsultations().removeIf(c -> c.getId().equals(itemId));
            case "vaccinations" -> record.getVaccinations().removeIf(v -> v.getId().equals(itemId));
            case "allergies" -> record.getAllergies().removeIf(a -> a.getId().equals(itemId));
            case "medications" -> record.getMedications().removeIf(m -> m.getId().equals(itemId));
            default -> throw new ResourceNotFoundException("Unknown medical record section: " + section);
        }
        return repository.save(record);
    }

    private MedicalRecord createEmpty(String petId) {
        if (!petService.exists(petId)) {
            throw new ResourceNotFoundException("Pet", petId);
        }
        return repository.save(MedicalRecord.builder().petId(petId).build());
    }

    private String newId() {
        return UUID.randomUUID().toString();
    }
}
