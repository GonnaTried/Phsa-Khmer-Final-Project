package com.phaskhmer.st25.spring_boot.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.phaskhmer.st25.spring_boot.model.ProductHistory;

@Repository
public interface ProductHistoryRepository extends JpaRepository<ProductHistory, Long> {

    Optional<ProductHistory> findTopByProductIdOrderByChangedAtDesc(Long productId);

    List<ProductHistory> findAllByProductIdOrderByChangedAtAsc(Long productId);
}
