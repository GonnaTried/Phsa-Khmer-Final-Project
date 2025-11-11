package com.phaskhmer.st25.spring_boot.repository;

import java.time.Instant;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.phaskhmer.st25.spring_boot.model.SellerEarning;

@Repository
public interface SellerEarningRepository extends JpaRepository<SellerEarning, Long> {

    List<SellerEarning> findBySellerId(Long sellerId);

    List<SellerEarning> findBySellerIdAndTransactionDateBetween(Long sellerId, Instant startDate, Instant endDate);
}
