package com.petcare.marketplace.service;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import com.petcare.marketplace.dto.ProductRequest;
import com.petcare.marketplace.dto.ProductResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ProductService {

    Page<ProductResponse> list(ProductCategory category, Pageable pageable);

    ProductResponse getById(String id);

    /** Accès interne (ex. commande) : charge l'entité produit. */
    Product getEntity(String id);

    /** Persiste une entité produit (ex. mise à jour du stock lors d'une commande). */
    Product save(Product product);

    ProductResponse create(ProductRequest request);

    ProductResponse update(String id, ProductRequest request);

    void delete(String id);
}
