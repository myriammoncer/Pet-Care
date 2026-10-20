package com.petcare.event.dto;

import com.petcare.event.domain.EventType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.Instant;

public record EventRequest(
        @NotBlank String title,
        String description,
        @NotNull EventType type,
        @NotNull Instant startAt,
        Instant endAt,
        @NotBlank String location,
        @Positive int capacity
) {
}
