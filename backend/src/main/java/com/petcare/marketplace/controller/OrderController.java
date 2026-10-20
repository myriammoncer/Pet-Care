package com.petcare.marketplace.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.common.dto.PageResponse;
import com.petcare.common.security.SecurityUtils;
import com.petcare.marketplace.dto.CreateOrderRequest;
import com.petcare.marketplace.dto.OrderResponse;
import com.petcare.marketplace.dto.UpdateOrderStatusRequest;
import com.petcare.marketplace.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Commandes (/orders).
 */
@RestController
@RequestMapping("/orders")
@Tag(name = "Orders", description = "Commandes de la marketplace")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    @Operation(summary = "Valider le panier en commande")
    public ResponseEntity<ApiResponse<OrderResponse>> checkout(@Valid @RequestBody CreateOrderRequest request) {
        OrderResponse order = orderService.checkout(SecurityUtils.currentUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(order));
    }

    @GetMapping
    @Operation(summary = "Mes commandes")
    public ApiResponse<PageResponse<OrderResponse>> list(Pageable pageable) {
        return ApiResponse.ok(PageResponse.from(orderService.listForUser(SecurityUtils.currentUserId(), pageable)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'une commande")
    public ApiResponse<OrderResponse> getById(@PathVariable String id) {
        return ApiResponse.ok(orderService.getById(id, SecurityUtils.currentUserId(), SecurityUtils.isAdmin()));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Mettre à jour le statut d'une commande (admin)")
    public ApiResponse<OrderResponse> updateStatus(@PathVariable String id,
                                                   @Valid @RequestBody UpdateOrderStatusRequest request) {
        return ApiResponse.ok(orderService.updateStatus(id, request.status()));
    }
}
