package com.phaskhmer.st25.spring_boot.controller.payment;

import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import com.phaskhmer.st25.spring_boot.repository.CartRepository;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.StripeObject;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/stripe-webhook")
public class WebhookController {

    @Value("${stripe.webhook.secret}")
    private String webhookSecret;

    private final OrderRepository orderRepository;
    private final CartRepository cartRepository;

    public WebhookController(OrderRepository orderRepository, CartRepository cartRepository) {
        this.orderRepository = orderRepository;
        this.cartRepository = cartRepository;
    }

    @PostMapping
    @Transactional
    public ResponseEntity<String> handleStripeWebhook(@RequestBody String payload, @RequestHeader("Stripe-Signature") String sigHeader) {

        Event event;

        // 1. Verify webhook signature
        try {
            event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
        } catch (SignatureVerificationException e) {
            // Invalid signature
            System.err.println("Webhook Signature Error: " + e.getMessage());
            return ResponseEntity.badRequest().body("Invalid signature");
        }

        // 2. Handle the event type
        if ("checkout.session.completed".equals(event.getType())) {

            StripeObject stripeObject = event.getDataObjectDeserializer().getObject()
                    .orElseThrow(() -> new RuntimeException("Could not deserialize Stripe object."));

            // Cast to the relevant object
            Session session = (Session) stripeObject;

            // Retrieve metadata keys
            String compositeOrderIdsStr = session.getMetadata().get("order_ids");
            String customerIdStr = session.getMetadata().get("customer_id");


            // FIX 1: Handle null or missing metadata
            if (compositeOrderIdsStr == null || customerIdStr == null) {
                System.err.println("Metadata missing in Stripe Session: order_id=" + compositeOrderIdsStr + ", customer_id=" + customerIdStr);
                // Return success if we can't process it, so Stripe stops retrying,
                // but log the error.
                return ResponseEntity.status(400).body("Missing required metadata.");
            }

            Long customerId;
            try {
                customerId = Long.parseLong(customerIdStr);
            } catch (NumberFormatException e) {
                System.err.println("Invalid customer ID format: " + customerIdStr);
                return ResponseEntity.status(400).body("Invalid customer ID format.");
            }

            // FIX 2: Parse the composite ID string (e.g., "123_124_125")
            List<Long> orderIds;
            try {
                orderIds = Arrays.stream(compositeOrderIdsStr.split("_"))
                        .map(Long::parseLong)
                        .collect(Collectors.toList());
            } catch (NumberFormatException e) {
                System.err.println("Invalid composite order ID format: " + compositeOrderIdsStr);
                return ResponseEntity.status(400).body("Invalid composite order ID format.");
            }


            // 3. Fulfill the purchase (update database) for all linked orders
            for (Long orderId : orderIds) {
                orderRepository.findById(orderId).ifPresent(order -> {
                    if (order.getStatus().equals(OrderStatus.PENDING)) {
                        // Set order status to PAID
                        order.setStatus(OrderStatus.PAID);
                        order.setPaymentIntentId(session.getPaymentIntent()); // Store PI for refunds
                        orderRepository.save(order);
                        System.out.println("Order " + orderId + " successfully paid and fulfilled.");
                    }
                });
            }


            // 4. Clear the customer's cart
            // This is done once, after all orders have been processed.
            cartRepository.findByCustomerId(customerId).ifPresent(cart -> {
                cart.getItems().clear();
                cartRepository.save(cart);
                System.out.println("Cart cleared for customer: " + customerId);
            });

            // TODO: Deduct inventory (stock management)
            // TODO: Send confirmation email
        }

        // Handle other relevant events (e.g., 'payment_intent.payment_failed') here.

        return ResponseEntity.ok("Received");
    }
}