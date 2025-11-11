package com.phaskhmer.st25.spring_boot.model;

import java.math.BigDecimal;
import java.time.Instant;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "seller_earnings")
@Data
@NoArgsConstructor
public class SellerEarning {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long sellerId;

    private Long orderItemId;

    private Instant transactionDate;

    private BigDecimal saleAmount;
    private BigDecimal platformFee;
    private BigDecimal netEarning;

    private String paymentStatus;

    private String payoutBatchId;
}
