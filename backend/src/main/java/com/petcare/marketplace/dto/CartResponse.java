package com.petcare.marketplace.dto;

import java.util.List;

/**
 * Panier enrichi : chaque ligne porte le détail produit et le sous-total.
 */
public record CartResponse(
        String userId,
        List<Line> items,
        double totalAmount,
        String currency
) {
    public record Line(
            String productId,
            String productName,
            double unitPrice,
            int quantity,
            double subtotal
    ) {
    }
}
