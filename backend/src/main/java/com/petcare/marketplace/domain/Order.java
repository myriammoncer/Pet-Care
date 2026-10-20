package com.petcare.marketplace.domain;

import com.petcare.common.domain.AuditableDocument;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

/**
 * Commande passée par un utilisateur (collection {@code orders}).
 * Les lignes figent le nom et le prix au moment de l'achat.
 */
@Document(collection = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order extends AuditableDocument {

    @Indexed
    private String userId;

    @Builder.Default
    private List<OrderItem> items = new ArrayList<>();

    private double totalAmount;
    @Builder.Default
    private String currency = "EUR";

    @Indexed
    @Builder.Default
    private OrderStatus status = OrderStatus.PENDING;

    private Address shippingAddress;

    /** Ligne de commande figée. */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class OrderItem {
        private String productId;
        private String productName;
        private double unitPrice;
        private int quantity;
    }

    /** Adresse de livraison embarquée. */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Address {
        private String street;
        private String city;
        private String zipCode;
        private String country;
    }
}
