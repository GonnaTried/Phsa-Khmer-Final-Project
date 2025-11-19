package com.phaskhmer.st25.spring_boot.controller;

import com.phaskhmer.st25.spring_boot.model.cart.Cart;
import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import com.phaskhmer.st25.spring_boot.repository.CartRepository;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import com.phaskhmer.st25.spring_boot.service.StripeService;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/checkout")
public class CheckoutController {

    private final StripeService stripeService;
    private final CartRepository cartRepository;
    private final OrderRepository orderRepository;

    public CheckoutController(StripeService stripeService, CartRepository cartRepository, OrderRepository orderRepository) {
        this.stripeService = stripeService;
        this.cartRepository = cartRepository;
        this.orderRepository = orderRepository;
    }

    // DTO for response to Flutter
    public static class CheckoutResponse {
        public final String sessionUrl;
        public final String sessionId;

        public CheckoutResponse(String sessionUrl, String sessionId) {
            this.sessionUrl = sessionUrl;
            this.sessionId = sessionId;
        }
    }

    /**
     * Endpoint to initiate the Stripe Checkout flow.
     * @param customerId The ID of the customer initiating checkout.
     * @return Stripe Session URL and Session ID.
     */
    @PostMapping("/{customerId}")
    @Transactional
    public ResponseEntity<?> initiateCheckout(@PathVariable Long customerId) {

        // 1. Get the current cart for the customer
        Cart cart = cartRepository.findByCustomerId(customerId)
                .orElseThrow(() -> new RuntimeException("Cart not found for customer: " + customerId));

        if (cart.getItems().isEmpty()) {
            return ResponseEntity.badRequest().body("Cart is empty.");
        }

        // Calculate Total Amount (assuming prices are BigDecimal)
        BigDecimal totalAmount = cart.getItems().stream()
                .map(item -> item.getItem().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 2. Create a PENDING Order in the database
        // NOTE: In a robust system, you'd manage shipping address, etc., here.
        Order pendingOrder = new Order();
        pendingOrder.setCustomer(cart.getCustomer()); // Assume Cart has a Customer reference
        pendingOrder.setTotalAmount(totalAmount);
        pendingOrder.setStatus(OrderStatus.PENDING);
        // ... populate OrderItems from CartItems ...

        // Simulating the creation of OrderItems (required for total calculation)
        // You need to ensure your order creation logic copies items from cart to order
        // For simplicity here, we assume the Order is fully created and saved:
        Order savedOrder = orderRepository.save(pendingOrder);

        try {
            // 3. Create the Stripe Session
            Session session = stripeService.createCheckoutSession(
                    cart.getItems(),
                    customerId,
                    savedOrder.getId()
            );

            // 4. Update the Order with the Stripe Session ID
            savedOrder.setStripeSessionId(session.getId());
            orderRepository.save(savedOrder);

            // 5. Return the URL and ID to Flutter
            return ResponseEntity.ok(new CheckoutResponse(
                    session.getUrl(),
                    session.getId()
            ));

        } catch (StripeException e) {
            System.err.println("Stripe Error: " + e.getMessage());
            // Optional: Delete the pending order if Stripe fails
            // orderRepository.delete(savedOrder);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("error", "Stripe payment initiation failed."));
        }
    }
}