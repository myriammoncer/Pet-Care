package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import java.util.List;

/**
 * Données de référence pour la catégorie TRANSPORT.
 * 1 produit unique, 1 produit = 1 image unique du dossier
 * {@code assets/images/marketplace/transport/}.
 */
public final class TransportSeedData {

    private TransportSeedData() {
    }

    public static List<Product> products() {
        return List.of(
            Product.builder().name("Sac de Voyage Confort Première Classe")
                .description("Structure renforcée respirante avec ouverture panoramique et fond rembourré amovible pour des trajets sereins.")
                .category(ProductCategory.TRANSPORT).photoUrl("assets/images/marketplace/transport/sac_transport.jpg")
                .price(54.00).currency("EUR").stock(8).active(true).build()
        );
    }
}