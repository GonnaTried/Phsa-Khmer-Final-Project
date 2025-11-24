package com.phaskhmer.st25.spring_boot.controller;

import com.phaskhmer.st25.spring_boot.dto.order.OrderDTO;
import com.phaskhmer.st25.spring_boot.model.Customer;
import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.repository.CustomerRepository;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import com.phaskhmer.st25.spring_boot.service.OrderMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final CustomerRepository customerRepository;
    private final OrderRepository orderRepository;

    public OrderController(CustomerRepository customerRepository, OrderRepository orderRepository) {
        this.customerRepository = customerRepository;
        this.orderRepository = orderRepository;
    }
    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String customerIdString = authentication.getName();
        Long customerId = Long.parseLong(customerIdString);
        return customerId;
    }

    @GetMapping("/history")
    public ResponseEntity<List<OrderDTO>> getOrderHistory() {
        Long customerId = getCurrentUserId();

        return customerRepository.findById(customerId)
                .map(customer -> {
                    List<Order> orders = orderRepository.findByCustomerOrderByIdDesc(customer);

                    List<OrderDTO> orderDTOs = OrderMapper.toDtoList(orders);

                    return ResponseEntity.ok(orderDTOs);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}