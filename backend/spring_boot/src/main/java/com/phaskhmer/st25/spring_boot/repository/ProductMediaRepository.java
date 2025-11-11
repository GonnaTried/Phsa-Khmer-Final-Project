package com.phaskhmer.st25.spring_boot.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.phaskhmer.st25.spring_boot.model.ProductMedia;

@Repository
public interface ProductMediaRepository extends JpaRepository<ProductMedia, Long> {

    List<ProductMedia> findByProductIdOrderBySortOrderAsc(Long productId);

    Optional<ProductMedia> findByProductIdAndIsPrimaryTrue(Long productId);

    Optional<ProductMedia> findByMediaUrl(String mediaUrl);
}
