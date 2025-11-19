package com.phaskhmer.st25.spring_boot.repository;

import java.util.Optional;
import com.phaskhmer.st25.spring_boot.model.cart.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    Optional<CartItem> findByCartIdAndItemId(Long cartId, Long itemId);
}