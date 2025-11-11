package com.phaskhmer.st25.spring_boot.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.phaskhmer.st25.spring_boot.model.Order;
import com.phaskhmer.st25.spring_boot.service.OrderService;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    private Long getCurrentUserId() {
        return Long.parseLong(org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getName());
    }

    // --- Buyer Actions ---
    @PostMapping("/checkout")
    public ResponseEntity<Order> placeOrder(@RequestBody Map<String, Object> checkoutRequest) {

        Long buyerId = getCurrentUserId();

        Long shippingAddressId = Long.valueOf(checkoutRequest.get("shippingAddressId").toString());
        List<Long> productIds = (List<Long>) checkoutRequest.get("productIds");
        List<Integer> quantities = (List<Integer>) checkoutRequest.get("quantities");

        try {
            Order order = orderService.createOrder(buyerId, shippingAddressId, productIds, quantities);
            return new ResponseEntity<>(order, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/my-history")
    public List<Order> getOrderHistory() {
        Long buyerId = getCurrentUserId();
        return orderService.getOrdersByBuyer(buyerId);
    }

    // --- Seller/Fulfillment Actions (Requires Authorization/Roles in future) ---
    @PutMapping("/{orderId}/status")
    public ResponseEntity<Order> updateOrderStatus(@PathVariable Long orderId, @RequestParam Order.OrderStatus status) {

        try {
            Order updatedOrder = orderService.updateOrderStatus(orderId, status);
            return ResponseEntity.ok(updatedOrder);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
