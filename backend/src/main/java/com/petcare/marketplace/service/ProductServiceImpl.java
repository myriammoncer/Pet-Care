package com.petcare.marketplace.service;

import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import com.petcare.marketplace.dto.ProductRequest;
import com.petcare.marketplace.dto.ProductResponse;
import com.petcare.marketplace.repository.ProductRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
public class ProductServiceImpl implements ProductService {

    private final ProductRepository repository;

    public ProductServiceImpl(ProductRepository repository) {
        this.repository = repository;
    }

    @Override
    public Page<ProductResponse> list(ProductCategory category, Pageable pageable) {
        Page<Product> page = (category == null)
                ? repository.findByActiveTrue(pageable)
                : repository.findByCategoryAndActiveTrue(category, pageable);
        return page.map(ProductResponse::from);
    }

    @Override
    public ProductResponse getById(String id) {
        return ProductResponse.from(getEntity(id));
    }

    @Override
    public Product getEntity(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product", id));
    }

    @Override
    public Product save(Product product) {
        return repository.save(product);
    }

    @Override
    public ProductResponse create(ProductRequest r) {
        Product product = Product.builder()
                .name(r.name()).description(r.description()).category(r.category())
                .price(r.price()).currency(r.currency() == null ? "EUR" : r.currency())
                .stock(r.stock()).photoUrl(r.photoUrl())
                .active(r.active() == null || r.active())
                .build();
        return ProductResponse.from(repository.save(product));
    }

    @Override
    public ProductResponse update(String id, ProductRequest r) {
        Product product = getEntity(id);
        product.setName(r.name());
        product.setDescription(r.description());
        product.setCategory(r.category());
        product.setPrice(r.price());
        if (r.currency() != null) product.setCurrency(r.currency());
        product.setStock(r.stock());
        product.setPhotoUrl(r.photoUrl());
        if (r.active() != null) product.setActive(r.active());
        return ProductResponse.from(repository.save(product));
    }

    @Override
    public void delete(String id) {
        repository.delete(getEntity(id));
    }
}
