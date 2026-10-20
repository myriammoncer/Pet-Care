package com.petcare.pet.domain;

import com.petcare.common.domain.AuditableDocument;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDate;

/**
 * Profil d'un animal de compagnie (collection {@code pets}).
 */
@Document(collection = "pets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Pet extends AuditableDocument {

    /** Référence vers le propriétaire (users._id). */
    @Indexed
    private String ownerId;

    private String name;
    private Species species;
    private String breed;
    private LocalDate birthDate;
    private Sex sex;
    private Double weight;
    private String color;
    private String photoUrl;

    /** Numéro de puce électronique (unique lorsqu'il est renseigné). */
    @Indexed(unique = true, sparse = true)
    private String microchipNumber;

    @Builder.Default
    private PetStatus status = PetStatus.HEALTHY;
}
