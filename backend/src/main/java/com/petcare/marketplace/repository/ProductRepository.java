package com.petcare.marketplace.repository;

import com.petcare.marketplace.domain.Product;
import com.petcare.marketplace.domain.ProductCategory;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ProductRepository extends MongoRepository<Product, String> {

    Page<Product> findByActiveTrue(Pageable pageable);

    Page<Product> findByCategoryAndActiveTrue(ProductCategory category, Pageable pageable);

    List<Product> findByCategory(ProductCategory category);

    void deleteAllByCategory(ProductCategory category);
}
