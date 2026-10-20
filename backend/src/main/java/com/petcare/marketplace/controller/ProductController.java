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
    @PreAuthorize("hasRole('ADMIN')")
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
}
