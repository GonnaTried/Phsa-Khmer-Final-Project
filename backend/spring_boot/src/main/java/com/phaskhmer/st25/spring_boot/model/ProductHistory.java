package com.phaskhmer.st25.spring_boot.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "product_history")
@Data
@NoArgsConstructor
public class ProductHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long productId;

    private Long changedBySellerId;

    private BigDecimal price;

    private Integer stockQuantity;

    private Instant changedAt;

    public ProductHistory(Product product, Long sellerId) {
        this.productId = product.getId();
        this.changedBySellerId = sellerId;
        this.price = product.getPrice();
        this.stockQuantity = product.getStockQuantity();
        this.changedAt = Instant.now();
    }
}
