package com.phaskhmer.st25.spring_boot.repository;


import com.phaskhmer.st25.spring_boot.model.Customer;
import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByCustomer(Customer customer);
    List<Order> findByStatusNot(OrderStatus status);
    List<Order> findByCustomerOrderByIdDesc(Customer customer);
    List<Order> findOrdersByCustomerAndStatus(Customer customer, OrderStatus status);
    List<Order> findByStripeSessionId(String stripeSessionId);

    @Query("""
        SELECT DISTINCT o FROM Order o 
        JOIN o.items oi 
        JOIN oi.item i 
        JOIN i.listing l              
        WHERE l.seller.id = :sellerId 
        AND o.status = :status 
        AND o.customer.id != :sellerId 
        ORDER BY o.orderDate DESC
        """)
    List<Order> findSellerOrdersBySellerIdAndStatus(
            @Param("sellerId") Long sellerId,
            @Param("status") OrderStatus status
    );
}
