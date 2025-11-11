package com.phaskhmer.st25.spring_boot.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.phaskhmer.st25.spring_boot.model.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    java.util.List<Product> findBySellerId(Long sellerId);

    List<Product> findByNameContainingIgnoreCase(String name);
}
