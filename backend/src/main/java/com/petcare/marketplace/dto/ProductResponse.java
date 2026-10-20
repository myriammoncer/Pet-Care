package com.petcare.marketplace.dto;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;

public record ProductResponse(
        String id,
        String name,
        String description,
        ProductCategory category,
        double price,
        String currency,
        int stock,
        String photoUrl,
        boolean active
) {
    public static ProductResponse from(Product p) {
        return new ProductResponse(p.getId(), p.getName(), p.getDescription(), p.getCategory(),
                p.getPrice(), p.getCurrency(), p.getStock(), p.getPhotoUrl(), p.isActive());
    }
}
