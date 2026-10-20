package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.OrderStatus;
import com.petcare.marketplace.dto.CreateOrderRequest;
import com.petcare.marketplace.dto.OrderResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface OrderService {

    /** Transforme le panier courant en commande puis vide le panier. */
    OrderResponse checkout(String userId, CreateOrderRequest request);

    Page<OrderResponse> listForUser(String userId, Pageable pageable);

    OrderResponse getById(String orderId, String requesterId, boolean isAdmin);

    OrderResponse updateStatus(String orderId, OrderStatus status);
}
