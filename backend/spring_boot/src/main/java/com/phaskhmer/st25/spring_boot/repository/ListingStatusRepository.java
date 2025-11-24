package com.phaskhmer.st25.spring_boot.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.phaskhmer.st25.spring_boot.model.listing.ListingStatus;

public interface ListingStatusRepository extends JpaRepository<ListingStatus, Long> {

}
