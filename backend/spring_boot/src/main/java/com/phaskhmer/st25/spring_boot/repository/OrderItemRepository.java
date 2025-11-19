package com.phaskhmer.st25.spring_boot.repository;

//import com.phaskhmer.st25.spring_boot.model.OrderItem;
import com.phaskhmer.st25.spring_boot.model.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
}
