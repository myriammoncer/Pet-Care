package com.petcare.marketplace.service;

import com.petcare.marketplace.dto.CartItemRequest;
import com.petcare.marketplace.dto.CartResponse;

public interface CartService {

    CartResponse getCart(String userId);

    CartResponse addOrUpdateItem(String userId, CartItemRequest request);

    CartResponse removeItem(String userId, String productId);

    void clear(String userId);
}
