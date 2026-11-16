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

    /**
     * Purge tous les produits de la catégorie ALIMENTATION puis recrée les 10 produits
     * de référence avec mapping biunivoque 1 produit = 1 image unique.
     *
     * @return le nombre de produits recréés (doit être 10)
     */
    int reseedAlimentation();

    /**
     * Purge tous les produits de la catégorie JOUETS puis recrée les 5 produits
     * de référence avec mapping biunivoque 1 produit = 1 image unique.
     *
     * @return le nombre de produits recréés (doit être 5)
     */
    int reseedJouets();

    /**
     * Purge tous les produits de la catégorie NICHE & COUCHAGE puis recrée les 6 produits
     * de référence avec mapping biunivoque 1 produit = 1 image unique.
     *
     * @return le nombre de produits recréés (doit être 6)
     */
    int reseedNicheCouchage();

    /**
     * Purge tous les produits de la catégorie HYGIÈNE & SOINS puis recrée les 5 produits
     * de référence avec mapping biunivoque 1 produit = 1 image unique.
     *
     * @return le nombre de produits recréés (doit être 5)
     */
    int reseedHygieneSoins();

    /**
     * Purge tous les produits de la catégorie ACCESSOIRES puis recrée les 5 produits
     * de référence avec mapping biunivoque 1 produit = 1 image unique.
     *
     * @return le nombre de produits recréés (doit être 5)
     */
    int reseedAccessoires();

    /**
     * Purge tous les produits de la catégorie TRANSPORT puis recrée le produit
     * de référence avec mapping biunivoque 1 produit = 1 image unique.
     *
     * @return le nombre de produits recréés (doit être 1)
     */
    int reseedTransport();

    /**
     * Purge toutes les catégories puis recrée l'ensemble des 32 produits de référence
     * (10 ALIMENTATION + 5 JOUETS + 6 NICHE_COUCHAGE + 5 HYGIENE_SOINS +
     * 5 ACCESSORIES + 1 TRANSPORT).
     *
     * @return le nombre total de produits recréés (doit être 32)
     */
    int reseedAll();
}
