package com.petcare.marketplace.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.common.security.SecurityUtils;
import com.petcare.marketplace.dto.CartItemRequest;
import com.petcare.marketplace.dto.CartResponse;
import com.petcare.marketplace.service.CartService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Panier de l'utilisateur courant (/cart).
 */
@RestController
@RequestMapping("/cart")
@Tag(name = "Cart", description = "Panier d'achat")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping
    @Operation(summary = "Panier courant")
    public ApiResponse<CartResponse> getCart() {
        return ApiResponse.ok(cartService.getCart(SecurityUtils.currentUserId()));
    }

    @PostMapping("/items")
    @Operation(summary = "Ajouter ou mettre à jour une ligne")
    public ApiResponse<CartResponse> addItem(@Valid @RequestBody CartItemRequest request) {
        return ApiResponse.ok(cartService.addOrUpdateItem(SecurityUtils.currentUserId(), request));
    }

    @DeleteMapping("/items/{productId}")
    @Operation(summary = "Retirer une ligne du panier")
    public ApiResponse<CartResponse> removeItem(@PathVariable String productId) {
        return ApiResponse.ok(cartService.removeItem(SecurityUtils.currentUserId(), productId));
    }

    @DeleteMapping
    @Operation(summary = "Vider le panier")
    public ResponseEntity<Void> clear() {
        cartService.clear(SecurityUtils.currentUserId());
        return ResponseEntity.noContent().build();
    }
}
