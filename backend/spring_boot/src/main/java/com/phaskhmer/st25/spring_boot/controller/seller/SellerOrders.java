package com.phaskhmer.st25.spring_boot.controller.seller;

import com.phaskhmer.st25.spring_boot.dto.order.OrderDTO;
import com.phaskhmer.st25.spring_boot.dto.order.OrderStatusUpdateDTO;
import com.phaskhmer.st25.spring_boot.model.Customer;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import com.phaskhmer.st25.spring_boot.repository.CustomerRepository;
import com.phaskhmer.st25.spring_boot.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/seller/orders")
@RequiredArgsConstructor
public class SellerOrders {
    private final OrderService orderService;
    private final CustomerRepository customerRepository;

    private Customer getCurrentSeller() {
        Long sellerId = getCurrentPrincipalId();

        // 2. Fetch the Customer entity from the database
        Customer seller = customerRepository.findById(sellerId)
                .orElseThrow(() -> new IllegalStateException("Authenticated user (ID: " + sellerId + ") not found in the database."));

//        if (!Boolean.TRUE.equals(seller.getIsSeller())) {
//            throw new IllegalStateException("Authenticated user is not authorized as a seller.");
//        }

        return seller;
    }

    private Long getCurrentPrincipalId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("User is not authenticated.");
        }

        Object principal = authentication.getPrincipal();
        String principalIdString;

        if (principal instanceof UserDetails) {
            principalIdString = ((UserDetails) principal).getUsername();
        } else {
            principalIdString = principal.toString();
        }

        try {
            return Long.valueOf(principalIdString.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid principal ID format in token: " + principalIdString, e);
        }
    }

    @GetMapping("/pending")
    public ResponseEntity<List<OrderDTO>> getPendingOrders() {
        Customer customer = getCurrentSeller();

        List<OrderDTO> orders = orderService.findSellerOrdersBySellerIdAndStatus(
                customer,
                OrderStatus.PAID
        );

        return ResponseEntity.ok(orders);
    }

    @GetMapping("/processing")
    public ResponseEntity<List<OrderDTO>> getProcessingOrders() {
        Customer customer = getCurrentSeller();

        List<OrderDTO> orders = orderService.findSellerOrdersBySellerIdAndStatus(
                customer,
                OrderStatus.PROCESSING
        );

        return ResponseEntity.ok(orders);
    }

    @GetMapping("/delivering")
    public ResponseEntity<List<OrderDTO>> getdeliveringOrders() {
        Customer customer = getCurrentSeller();

        List<OrderDTO> orders = orderService.findSellerOrdersBySellerIdAndStatus(
                customer,
                OrderStatus.DELIVERING
        );

        return ResponseEntity.ok(orders);
    }

    @GetMapping("/delivered")
    public ResponseEntity<List<OrderDTO>> getDeliveredOrders() {
        Customer customer = getCurrentSeller();

        List<OrderDTO> orders = orderService.findSellerOrdersBySellerIdAndStatus(
                customer,
                OrderStatus.DELIVERED
        );

        return ResponseEntity.ok(orders);
    }

    /**
     * Updates the status of a specific order item (single Order entity).
     * The order must belong to the authenticated seller.
     *
     * @param orderId The ID of the Order entity to update.
     * @param updateDTO DTO containing the new OrderStatus.
     * @return The updated Order DTO.
     */
    @PatchMapping("/{orderId}/status")
    public ResponseEntity<OrderDTO> updateOrderStatus(
            @PathVariable Long orderId,
            @Valid @RequestBody OrderStatusUpdateDTO updateDTO) {

        Customer seller = getCurrentSeller();

        try {
            OrderDTO updatedOrder = orderService.updateOrderStatus(
                    orderId,
                    seller.getId(),
                    updateDTO.getNewStatus()
            );
            return ResponseEntity.ok(updatedOrder);

        } catch (AccessDeniedException e) {
            return ResponseEntity.status(403).build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }
}


