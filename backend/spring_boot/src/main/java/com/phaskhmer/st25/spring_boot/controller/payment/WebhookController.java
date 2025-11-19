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

            // Retrieve metadata to find the corresponding order
            String orderIdStr = session.getMetadata().get("order_id");
            String customerIdStr = session.getMetadata().get("customer_id");
            Long orderId = Long.parseLong(orderIdStr);
            Long customerId = Long.parseLong(customerIdStr);

            // 3. Fulfill the purchase (update database)
            Order order = orderRepository.findById(orderId)
                    .orElseThrow(() -> new RuntimeException("Order not found: " + orderId));

            if (order.getStatus().equals(OrderStatus.PENDING)) {

                // Set order status to PAID
                order.setStatus(OrderStatus.PAID);
                order.setPaymentIntentId(session.getPaymentIntent()); // Store PI for refunds
                orderRepository.save(order);

                // Clear the customer's cart
                cartRepository.findByCustomerId(customerId).ifPresent(cart -> {
                    cart.getItems().clear();
                    cartRepository.save(cart);
                });

                // TODO: Deduct inventory (stock management)
                // TODO: Send confirmation email

                System.out.println("Order " + orderId + " successfully paid and fulfilled.");
            }
        }

        // Handle other relevant events (e.g., 'payment_intent.payment_failed') here.

        return ResponseEntity.ok("Received");
    }
}