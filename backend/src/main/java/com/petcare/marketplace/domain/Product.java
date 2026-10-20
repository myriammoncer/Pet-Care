package com.petcare.marketplace.domain;

import com.petcare.common.domain.AuditableDocument;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * Produit du catalogue marketplace (collection {@code products}).
 */
@Document(collection = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product extends AuditableDocument {

    private String name;
    private String description;

    @Indexed
    private ProductCategory category;

    private double price;
    @Builder.Default
    private String currency = "EUR";
    private int stock;
    private String photoUrl;

    @Builder.Default
    private boolean active = true;
}
