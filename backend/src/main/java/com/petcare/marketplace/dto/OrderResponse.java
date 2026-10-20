package com.petcare.marketplace.dto;

import com.petcare.marketplace.domain.Order;
import com.petcare.marketplace.domain.OrderStatus;

import java.time.Instant;
import java.util.List;

public record OrderResponse(
        String id,
        String userId,
        List<Order.OrderItem> items,
        double totalAmount,
        String currency,
        OrderStatus status,
        Order.Address shippingAddress,
        Instant createdAt
) {
    public static OrderResponse from(Order o) {
        return new OrderResponse(o.getId(), o.getUserId(), o.getItems(), o.getTotalAmount(),
                o.getCurrency(), o.getStatus(), o.getShippingAddress(), o.getCreatedAt());
    }
}
