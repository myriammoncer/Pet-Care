package com.petcare.marketplace.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

/**
 * Ajout / mise à jour d'une ligne de panier. Une quantité de 0 retire la ligne.
 */
public record CartItemRequest(
        @NotBlank String productId,
        @Positive int quantity
) {
}
