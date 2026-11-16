package com.petcare.event.dto;

import com.petcare.event.domain.EventType;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.time.Instant;

public record EventRequest(
        @NotBlank @Size(max = 120) String title,
        @Size(max = 2000) String description,
        @NotNull EventType type,
        @NotNull Instant startAt,
        Instant endAt,
        @NotBlank @Size(max = 200) String location,
        @Positive int capacity
) {
    /** La date de fin, si elle est fournie, doit être postérieure au début. */
    @AssertTrue(message = "endAt doit être postérieure à startAt")
    public boolean isEndAfterStart() {
        return endAt == null || startAt == null || endAt.isAfter(startAt);
    }
}
