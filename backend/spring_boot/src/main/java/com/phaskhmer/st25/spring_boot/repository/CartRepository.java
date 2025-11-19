package com.phaskhmer.st25.spring_boot.repository;

import java.util.Optional;
import com.phaskhmer.st25.spring_boot.model.cart.Cart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CartRepository extends JpaRepository<Cart, Long> {
    Optional<Cart> findByCustomerId(Long customerId);
}