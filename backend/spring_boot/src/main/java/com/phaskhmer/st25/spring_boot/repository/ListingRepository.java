package com.phaskhmer.st25.spring_boot.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.phaskhmer.st25.spring_boot.model.listing.Listing;

import java.util.List;

public interface ListingRepository extends JpaRepository<Listing, Long> {
    List<Listing> findBySellerId(Long sellerId);
}