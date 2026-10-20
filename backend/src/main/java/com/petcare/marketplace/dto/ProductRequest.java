package com.petcare.marketplace.dto;

import com.petcare.marketplace.domain.ProductCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

public record ProductRequest(
        @NotBlank String name,
        String description,
        @NotNull ProductCategory category,
        @PositiveOrZero double price,
        String currency,
        @PositiveOrZero int stock,
        String photoUrl,
        Boolean active
) {
}
