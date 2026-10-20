package com.petcare.marketplace.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Validation du panier en commande, avec l'adresse de livraison.
 */
public record CreateOrderRequest(
        @NotBlank String street,
        @NotBlank String city,
        @NotBlank String zipCode,
        @NotBlank String country
) {
}
