package com.petcare.marketplace.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.common.dto.PageResponse;
import com.petcare.marketplace.domain.ProductCategory;
import com.petcare.marketplace.dto.ProductRequest;
import com.petcare.marketplace.dto.ProductResponse;
import com.petcare.marketplace.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Catalogue produits (/products). Lecture : authentifié. Écriture : admin.
 */
@RestController
@RequestMapping("/products")
@Tag(name = "Products", description = "Catalogue de la marketplace")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    @Operation(summary = "Lister les produits (filtre optionnel par catégorie)")
    public ApiResponse<PageResponse<ProductResponse>> list(
            @RequestParam(required = false) ProductCategory category, Pageable pageable) {
        return ApiResponse.ok(PageResponse.from(productService.list(category, pageable)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'un produit")
    public ApiResponse<ProductResponse> getById(@PathVariable String id) {
        return ApiResponse.ok(productService.getById(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ADMIN')")
    @Operation(summary = "Créer un produit (admin)")
    public ResponseEntity<ApiResponse<ProductResponse>> create(@Valid @RequestBody ProductRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(productService.create(request)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Modifier un produit (admin)")
    public ApiResponse<ProductResponse> update(@PathVariable String id, @Valid @RequestBody ProductRequest request) {
        return ApiResponse.ok(productService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Supprimer un produit (admin)")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        productService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/reseed/alimentation")
    @Operation(summary = "Purger et recréer les 10 produits ALIMENTATION (admin)")
    public ApiResponse<Integer> reseedAlimentation() {
        int count = productService.reseedAlimentation();
        return ApiResponse.ok(count);
    }

    @PostMapping("/reseed/jouets")
    @Operation(summary = "Purger et recréer les 5 produits JOUETS (admin)")
    public ApiResponse<Integer> reseedJouets() {
        int count = productService.reseedJouets();
        return ApiResponse.ok(count);
    }

    @PostMapping("/reseed/niche-couchage")
    @Operation(summary = "Purger et recréer les 6 produits NICHE & COUCHAGE (admin)")
    public ApiResponse<Integer> reseedNicheCouchage() {
        int count = productService.reseedNicheCouchage();
        return ApiResponse.ok(count);
    }

    @PostMapping("/reseed/hygiene-soins")
    @Operation(summary = "Purger et recréer les 5 produits HYGIÈNE & SOINS (admin)")
    public ApiResponse<Integer> reseedHygieneSoins() {
        int count = productService.reseedHygieneSoins();
        return ApiResponse.ok(count);
    }

    @PostMapping("/reseed/accessoires")
    @Operation(summary = "Purger et recréer les 5 produits ACCESSOIRES (admin)")
    public ApiResponse<Integer> reseedAccessoires() {
        int count = productService.reseedAccessoires();
        return ApiResponse.ok(count);
    }

    @PostMapping("/reseed/transport")
    @Operation(summary = "Purger et recréer le produit TRANSPORT (admin)")
    public ApiResponse<Integer> reseedTransport() {
        int count = productService.reseedTransport();
        return ApiResponse.ok(count);
    }

    @PostMapping("/reseed/all")
    @Operation(summary = "Purger et recréer tous les 32 produits de toutes les catégories (admin)")
    public ApiResponse<Integer> reseedAll() {
        int count = productService.reseedAll();
        return ApiResponse.ok(count);
    }
}
