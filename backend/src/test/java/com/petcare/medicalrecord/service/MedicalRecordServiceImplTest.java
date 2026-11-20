package com.petcare.medicalrecord.service;

import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.medicalrecord.domain.MedicalRecord;
import com.petcare.medicalrecord.domain.MedicalRecord.Vaccination;
import com.petcare.medicalrecord.repository.MedicalRecordRepository;
import com.petcare.pet.service.PetService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MedicalRecordServiceImplTest {

    @Mock
    private MedicalRecordRepository repository;

    @Mock
    private PetService petService;

    @InjectMocks
    private MedicalRecordServiceImpl service;

    @Test
    void removeItemDeletesExistingEntryAndSavesRecord() {
        Vaccination vaccination = Vaccination.builder().id("vaccination-1").build();
        MedicalRecord record = MedicalRecord.builder()
                .petId("pet-1")
                .vaccinations(new ArrayList<>(List.of(vaccination)))
                .build();
        when(repository.findByPetId("pet-1")).thenReturn(Optional.of(record));
        when(repository.save(record)).thenReturn(record);

        service.removeItem("pet-1", "vaccinations", "vaccination-1");

        verify(repository).save(record);
        assertTrue(record.getVaccinations().isEmpty());
    }

    @Test
    void removeItemReportsMissingEntryInsteadOfSavingUnchangedRecord() {
        MedicalRecord record = MedicalRecord.builder()
                .petId("pet-1")
                .vaccinations(new ArrayList<>())
                .build();
        when(repository.findByPetId("pet-1")).thenReturn(Optional.of(record));

        assertThrows(
                ResourceNotFoundException.class,
                () -> service.removeItem("pet-1", "vaccinations", "missing")
        );

        verify(repository, never()).save(record);
    }
}
