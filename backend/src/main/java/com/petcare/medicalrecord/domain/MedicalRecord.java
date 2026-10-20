package com.petcare.medicalrecord.domain;

import com.petcare.common.domain.AuditableDocument;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Dossier médical d'un animal (collection {@code medical_records}).
 * Les éléments médicaux (consultations, vaccins, allergies, médicaments) sont
 * embarqués car toujours consultés dans le contexte de l'animal.
 * Voir docs/DATA_MODEL.md.
 */
@Document(collection = "medical_records")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MedicalRecord extends AuditableDocument {

    @Indexed(unique = true)
    private String petId;

    @Builder.Default
    private List<Consultation> consultations = new ArrayList<>();
    @Builder.Default
    private List<Vaccination> vaccinations = new ArrayList<>();
    @Builder.Default
    private List<Allergy> allergies = new ArrayList<>();
    @Builder.Default
    private List<Medication> medications = new ArrayList<>();

    /** Niveau de sévérité d'une allergie. */
    public enum AllergySeverity { LOW, MEDIUM, HIGH }

    /** Consultation / soin (historique médical). */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Consultation {
        private String id;
        private Instant date;
        private String reason;
        private String diagnosis;
        private String notes;
        private String vetId;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Vaccination {
        private String id;
        private String vaccineName;
        private LocalDate date;
        private LocalDate nextDueDate;
        private String vetId;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Allergy {
        private String id;
        private String substance;
        private AllergySeverity severity;
        private String reaction;
        private String notes;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Medication {
        private String id;
        private String name;
        private String dosage;
        private String frequency;
        private LocalDate startDate;
        private LocalDate endDate;
        private String prescribedBy;
    }
}
