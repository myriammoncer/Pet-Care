package com.petcare.medicalrecord.service;

import com.petcare.medicalrecord.domain.MedicalRecord;
import com.petcare.medicalrecord.dto.AllergyRequest;
import com.petcare.medicalrecord.dto.ConsultationRequest;
import com.petcare.medicalrecord.dto.MedicationRequest;
import com.petcare.medicalrecord.dto.VaccinationRequest;

/**
 * Gestion du dossier médical. L'écriture est réservée aux vétérinaires ;
 * la lecture est ouverte au propriétaire de l'animal, au vétérinaire et à l'admin.
 */
public interface MedicalRecordService {

    MedicalRecord getByPet(String petId);

    MedicalRecord addConsultation(String petId, String vetId, ConsultationRequest request);

    MedicalRecord addVaccination(String petId, String vetId, VaccinationRequest request);

    MedicalRecord addAllergy(String petId, AllergyRequest request);

    MedicalRecord addMedication(String petId, String vetId, MedicationRequest request);

    MedicalRecord removeItem(String petId, String section, String itemId);
}
