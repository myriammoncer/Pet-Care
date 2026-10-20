package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.Cart;
import com.petcare.marketplace.domain.Cart.CartItem;
import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.dto.CartItemRequest;
import com.petcare.marketplace.dto.CartResponse;
import com.petcare.marketplace.repository.CartRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class CartServiceImpl implements CartService {

    private final CartRepository cartRepository;
    private final ProductService productService;

    public CartServiceImpl(CartRepository cartRepository, ProductService productService) {
        this.cartRepository = cartRepository;
        this.productService = productService;
    }

    @Override
    public CartResponse getCart(String userId) {
        return toResponse(loadOrCreate(userId));
    }

    @Override
    public CartResponse addOrUpdateItem(String userId, CartItemRequest request) {
        // valide l'existence du produit
        productService.getEntity(request.productId());

        Cart cart = loadOrCreate(userId);
        cart.getItems().stream()
                .filter(i -> i.getProductId().equals(request.productId()))
                .findFirst()
                .ifPresentOrElse(
                        item -> item.setQuantity(request.quantity()),
                        () -> cart.getItems().add(CartItem.builder()
                                .productId(request.productId())
                                .quantity(request.quantity())
                                .build())
                );
        return toResponse(cartRepository.save(cart));
    }

    @Override
    public CartResponse removeItem(String userId, String productId) {
        Cart cart = loadOrCreate(userId);
        cart.getItems().removeIf(i -> i.getProductId().equals(productId));
        return toResponse(cartRepository.save(cart));
    }

    @Override
    public void clear(String userId) {
        Cart cart = loadOrCreate(userId);
        cart.getItems().clear();
        cartRepository.save(cart);
    }

    private Cart loadOrCreate(String userId) {
        return cartRepository.findByUserId(userId)
                .orElseGet(() -> cartRepository.save(Cart.builder().userId(userId).build()));
    }

    private CartResponse toResponse(Cart cart) {
        List<CartResponse.Line> lines = new ArrayList<>();
        double total = 0;
        String currency = "EUR";
        for (CartItem item : cart.getItems()) {
            Product product = productService.getEntity(item.getProductId());
            double subtotal = product.getPrice() * item.getQuantity();
            total += subtotal;
            currency = product.getCurrency();
            lines.add(new CartResponse.Line(product.getId(), product.getName(),
                    product.getPrice(), item.getQuantity(), subtotal));
        }
        return new CartResponse(cart.getUserId(), lines, total, currency);
    }
}
