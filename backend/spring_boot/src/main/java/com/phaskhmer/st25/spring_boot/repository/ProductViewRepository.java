package com.phaskhmer.st25.spring_boot.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.phaskhmer.st25.spring_boot.model.ProductView;

@Repository
public interface ProductViewRepository extends JpaRepository<ProductView, Long> {

    Optional<ProductView> findByProductIdAndViewDate(Long productId, LocalDate viewDate);

    List<ProductView> findByProductIdAndViewDateBetween(Long productId, LocalDate startDate, LocalDate endDate);
}
