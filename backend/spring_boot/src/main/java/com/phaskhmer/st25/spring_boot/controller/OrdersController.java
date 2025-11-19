package com.phaskhmer.st25.spring_boot.controller;

import com.phaskhmer.st25.spring_boot.model.Order;
import com.phaskhmer.st25.spring_boot.repository.CustomerRepository;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrdersController {

    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;

    private Long getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String userIdString;
        if (principal instanceof UserDetails) {
            userIdString = ((UserDetails) principal).getUsername();
        } else {
            userIdString = principal.toString();
        }
        return Long.valueOf(userIdString);
    }

    @GetMapping("/history")
    public ResponseEntity<List<Order>> getOrderHistory() {
        Long customerId = getCurrentUserId();
        return customerRepository.findById(customerId)
                .map(customer -> {
                    List<Order> orders = orderRepository.findByCustomer(customer);
                    return ResponseEntity.ok(orders);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
