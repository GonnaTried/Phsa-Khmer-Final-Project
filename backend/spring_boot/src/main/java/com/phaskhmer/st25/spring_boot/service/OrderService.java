package com.phaskhmer.st25.spring_boot.service;

import com.phaskhmer.st25.spring_boot.dto.order.OrderDTO;
import com.phaskhmer.st25.spring_boot.model.Customer;
import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderMapper orderMapper;

    public List<OrderDTO> findOrdersByCustomeridAndStatus(Customer customer, OrderStatus status) {

        List<Order> orders = orderRepository.findOrdersByCustomerAndStatus(customer, status);

        return OrderMapper.toDtoList(orders);
    }public List<OrderDTO> findSellerOrdersBySellerIdAndStatus(Customer customer, OrderStatus status) {

        List<Order> orders = orderRepository.findSellerOrdersBySellerIdAndStatus(customer.getId(), status);

        return OrderMapper.toDtoList(orders);
    }
    @Transactional
    public OrderDTO updateOrderStatus(Long orderId, Long sellerId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new EntityNotFoundException("Order not found with ID: " + orderId));

        // Security Check: Ensure the seller owns the item in this order
        // This assumes OrderItem links to Item, and Item links to Seller (Customer).
        // Since an Order can have multiple items, we must check ALL items.
        // Given your current model (1 order = 1 OrderItem = 1 Item), we check the first item.

        if (order.getItems().isEmpty()) {
            throw new IllegalStateException("Order has no items.");
        }

        // Check if the seller of the item matches the authenticated seller
        Long itemSellerId = order.getItems().get(0).getItem().getListing().getSeller().getId();

        if (!itemSellerId.equals(sellerId)) {
            throw new AccessDeniedException("Seller is not authorized to update this order.");
        }

        // Update logic
        if (newStatus == OrderStatus.PAID) {
            throw new IllegalArgumentException("Cannot manually revert status to PAID. This is set via webhook.");
        }

        order.setStatus(newStatus);
        Order updatedOrder = orderRepository.save(order);

        // Assuming you have a mechanism to convert Order entity to OrderDTO
        return orderMapper.toDto(updatedOrder);
    }
}
