package com.phaskhmer.st25.spring_boot.controller.payment;

import com.phaskhmer.st25.spring_boot.model.cart.Cart;
import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.model.order.OrderItem;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import com.phaskhmer.st25.spring_boot.repository.CartRepository;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import com.phaskhmer.st25.spring_boot.service.StripeService;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

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
        // Optionally, return the IDs of the orders created
        public final List<Long> createdOrderIds;

        public CheckoutResponse(String sessionUrl, String sessionId, List<Long> createdOrderIds) {
            this.sessionUrl = sessionUrl;
            this.sessionId = sessionId;
            this.createdOrderIds = createdOrderIds;
        }
    }

    /**
     * Endpoint to initiate the Stripe Checkout flow.
     * Creates a separate Order entity for each unique item in the cart.
     * @param customerId The ID of the customer initiating checkout.
     * @return Stripe Session URL and Session ID.
     */
    @PostMapping("/{customerId}")
    @Transactional
    public ResponseEntity<?> initiateCheckout(@PathVariable Long customerId) {

        Cart cart = cartRepository.findByCustomerId(customerId)
                .orElseThrow(() -> new RuntimeException("Cart not found for customer: " + customerId));

        if (cart.getItems().isEmpty()) {
            return ResponseEntity.badRequest().body("Cart is empty.");
        }

        // List to hold all orders created in this transaction
        List<Order> newOrders = new ArrayList<>();

        // List to hold Stripe line items for the single checkout session
        List<SessionCreateParams.LineItem> stripeLineItems = new ArrayList<>();

        // -----------------------------------------------------------------
        // 1. ITERATE OVER CART ITEMS TO CREATE SEPARATE ORDERS
        // -----------------------------------------------------------------

        for (var cartItem : cart.getItems()) {

            // Calculate the total amount for *this single item*
            BigDecimal itemTotalAmount = cartItem.getItem().getPrice()
                    .multiply(BigDecimal.valueOf(cartItem.getQuantity()));

            // 1.1. Create a PENDING Order for this single item
            Order pendingOrder = new Order();
            pendingOrder.setCustomer(cart.getCustomer());
            pendingOrder.setTotalAmount(itemTotalAmount);
            pendingOrder.setStatus(OrderStatus.PENDING);

            // 1.2. Create the single OrderItem for this order
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(pendingOrder);
            orderItem.setItem(cartItem.getItem());
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setUnitPrice(cartItem.getItem().getPrice());

            // Link the OrderItem back to the Order
            List<OrderItem> orderItems = new ArrayList<>();
            orderItems.add(orderItem);
            pendingOrder.setItems(orderItems);

            // 1.3. Save the single item order
            Order savedOrder = orderRepository.save(pendingOrder);
            newOrders.add(savedOrder);

            // 1.4. Prepare the corresponding Stripe Line Item
            // We use the Order ID in the metadata to link the payment back to the order(s)
            stripeLineItems.add(
                    stripeService.createStripeLineItem(
                            cartItem.getItem(),
                            cartItem.getQuantity(),
                            savedOrder.getId()
                    )
            );
        }

        // Ensure the cart is cleared or removed after creating orders (optional, but standard practice)
        // cartRepository.delete(cart);
        // OR
//        cartRepository.delete(cart);
//        cart.setItems(new ArrayList<>());
//        cartRepository.save(cart);


        try {
            // -----------------------------------------------------------------
            // 2. Create ONE Stripe Session covering ALL the Line Items
            // -----------------------------------------------------------------

            // We need a composite identifier for the success/cancel URLs,
            // or we use the first order's ID, or we rely purely on the webhook.
            String metaDataOrderId = newOrders.stream()
                    .map(order -> String.valueOf(order.getId()))
                    .collect(Collectors.joining("_"));

            Session session = stripeService.createCheckoutSessionFromLineItems(
                    stripeLineItems,
                    customerId,
                    metaDataOrderId // Use all IDs or a unique identifier
            );

            // -----------------------------------------------------------------
            // 3. Update ALL Orders with the SAME Stripe Session ID
            // -----------------------------------------------------------------

            List<Long> createdOrderIds = new ArrayList<>();
            for (Order order : newOrders) {
                order.setStripeSessionId(session.getId());
                orderRepository.save(order);
                createdOrderIds.add(order.getId());
            }

            // 4. Return the URL and ID to Flutter
            return ResponseEntity.ok(new CheckoutResponse(
                    session.getUrl(),
                    session.getId(),
                    createdOrderIds
            ));

        } catch (StripeException e) {
            System.err.println("Stripe Error: " + e.getMessage());
            // Optional: Handle cleanup if Stripe fails (delete the pending orders)
            // orderRepository.deleteAll(newOrders);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("error", "Stripe payment initiation failed."));
        }
    }
}