package com.petcare.marketplace.service;

import com.petcare.common.exception.ConflictException;
import com.petcare.common.exception.ForbiddenException;
import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.marketplace.domain.Order;
import com.petcare.marketplace.domain.Order.Address;
import com.petcare.marketplace.domain.Order.OrderItem;
import com.petcare.marketplace.domain.OrderStatus;
import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.dto.CartResponse;
import com.petcare.marketplace.dto.CreateOrderRequest;
import com.petcare.marketplace.dto.OrderResponse;
import com.petcare.marketplace.repository.OrderRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final CartService cartService;
    private final ProductService productService;

    public OrderServiceImpl(OrderRepository orderRepository, CartService cartService,
                            ProductService productService) {
        this.orderRepository = orderRepository;
        this.cartService = cartService;
        this.productService = productService;
    }

    @Override
    public OrderResponse checkout(String userId, CreateOrderRequest request) {
        CartResponse cart = cartService.getCart(userId);
        if (cart.items().isEmpty()) {
            throw new ConflictException("Cart is empty");
        }

        List<OrderItem> items = new ArrayList<>();
        double total = 0;
        String currency = "EUR";
        for (CartResponse.Line line : cart.items()) {
            Product product = productService.getEntity(line.productId());
            if (product.getStock() < line.quantity()) {
                throw new ConflictException("Insufficient stock for product " + product.getName());
            }
            // décrémente le stock puis persiste
            product.setStock(product.getStock() - line.quantity());
            productService.save(product);
            currency = product.getCurrency();
            items.add(OrderItem.builder()
                    .productId(product.getId())
                    .productName(product.getName())
                    .unitPrice(product.getPrice())
                    .quantity(line.quantity())
                    .build());
            total += product.getPrice() * line.quantity();
        }

        Order order = Order.builder()
                .userId(userId)
                .items(items)
                .totalAmount(total)
                .currency(currency)
                .status(OrderStatus.PENDING)
                .shippingAddress(Address.builder()
                        .street(request.street()).city(request.city())
                        .zipCode(request.zipCode()).country(request.country()).build())
                .build();

        order = orderRepository.save(order);
        cartService.clear(userId);
        return OrderResponse.from(order);
    }

    @Override
    public Page<OrderResponse> listForUser(String userId, Pageable pageable) {
        return orderRepository.findByUserId(userId, pageable).map(OrderResponse::from);
    }

    @Override
    public OrderResponse getById(String orderId, String requesterId, boolean isAdmin) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order", orderId));
        if (!isAdmin && !order.getUserId().equals(requesterId)) {
            throw new ForbiddenException("Access denied to order " + orderId);
        }
        return OrderResponse.from(order);
    }

    @Override
    public OrderResponse updateStatus(String orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order", orderId));
        order.setStatus(status);
        return OrderResponse.from(orderRepository.save(order));
    }
}
