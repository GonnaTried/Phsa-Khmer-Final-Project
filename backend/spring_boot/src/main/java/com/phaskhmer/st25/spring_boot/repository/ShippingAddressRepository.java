package com.phaskhmer.st25.spring_boot.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.phaskhmer.st25.spring_boot.model.ShippingAddress;

@Repository
public interface ShippingAddressRepository extends JpaRepository<ShippingAddress, Long> {

    List<ShippingAddress> findByCustomerId(Long customerId);

    Optional<ShippingAddress> findByCustomerIdAndIsDefaultTrue(Long customerId);
}
