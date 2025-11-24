package com.phaskhmer.st25.spring_boot.service;

import com.phaskhmer.st25.spring_boot.model.cart.CartItem;
import com.phaskhmer.st25.spring_boot.model.listing.Item;
import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class StripeService {

    @Value("${stripe.secret.key}")
    private String secretKey;

    @Value("${stripe.success.url}")
    private String successUrl;

    @Value("${stripe.cancel.url}")
    private String cancelUrl;

    @PostConstruct
    public void init() {
        Stripe.apiKey = secretKey;
    }

    /**
     * Creates a Stripe Checkout Session for the given cart items.
     *
     * @param cartItems  The items to be purchased.
     * @param customerId The ID of your internal customer (used in metadata).
     * @param orderId    The ID of the pending Order created in your DB (used in metadata).
     * @return The created Stripe Session.
     * @throws StripeException if the Stripe API call fails.
     */
    public Session createCheckoutSession(List<CartItem> cartItems, Long customerId, Long orderId) throws StripeException {

        // 1. Convert CartItems to Stripe Line Items
        List<SessionCreateParams.LineItem> lineItems = cartItems.stream()
                .map(item -> SessionCreateParams.LineItem.builder()
                        .setQuantity((long) item.getQuantity())
                        .setPriceData(
                                SessionCreateParams.LineItem.PriceData.builder()
                                        .setCurrency("usd") // Change this to your desired currency (e.g., "thb", "eur")
                                        // Price is in the smallest currency unit (cents/satang/etc.)
                                        .setUnitAmount(item.getItem().getPrice().movePointRight(2).longValue())
                                        .setProductData(
                                                SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                        .setName(item.getItem().getName())
                                                        .addImage(item.getItem().getImageUrl())
                                                        .build())
                                        .build())
                        .build())
                .collect(Collectors.toList());

        // 2. Build the Session Parameters
        SessionCreateParams params = SessionCreateParams.builder()
                .addPaymentMethodType(SessionCreateParams.PaymentMethodType.CARD)
                // Can add other methods like SessionCreateParams.PaymentMethodType.PAYPAL if enabled
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(successUrl)
                .setCancelUrl(cancelUrl)
                .addAllLineItem(lineItems)
                // Optional: Set customer email if you have it
                // .setCustomerEmail("customer@example.com")

                // 3. Add Metadata for Webhook processing later
                .putMetadata("customer_id", String.valueOf(customerId))
                .putMetadata("order_id", String.valueOf(orderId))

                .build();

        // 4. Create and return the session
        return Session.create(params);
    }

    /**
     * Creates a single Stripe Checkout Session from a list of pre-built Line Items.
     * This is used when a single checkout covers multiple internal Order entities.
     *
     * @param lineItems             The pre-built Stripe Line Items (one for each created order).
     * @param customerId            The ID of your internal customer.
     * @param uniqueOrderIdMetadata A string containing all related Order IDs (e.g., "1_2_3").
     * @return The created Stripe Session.
     * @throws StripeException if the Stripe API call fails.
     */
    public Session createCheckoutSessionFromLineItems(
            List<SessionCreateParams.LineItem> lineItems,
            Long customerId,
            String uniqueOrderIdMetadata) throws StripeException {

        if (lineItems.isEmpty()) {
            throw new IllegalArgumentException("Line items list cannot be empty for checkout session creation.");
        }

        // 1. Build the Session Parameters
        SessionCreateParams params = SessionCreateParams.builder()
                .addPaymentMethodType(SessionCreateParams.PaymentMethodType.CARD)
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(successUrl)
                .setCancelUrl(cancelUrl)
                .addAllLineItem(lineItems)

                // 2. Add Metadata for Webhook processing later
                .putMetadata("customer_id", String.valueOf(customerId))
                // Store all order IDs created in this transaction
                .putMetadata("order_ids", uniqueOrderIdMetadata)

                .build();

        // 3. Create and return the session
        return Session.create(params);
    }

    /**
     * Helper to create a single Stripe Line Item, attaching the Order ID to the PriceData metadata.
     */
    public SessionCreateParams.LineItem createStripeLineItem(
            Item item,
            int quantity,
            Long relatedOrderId) {

        return SessionCreateParams.LineItem.builder()
                .setQuantity((long) quantity)
                .setPriceData(
                        SessionCreateParams.LineItem.PriceData.builder()
                                .setCurrency("usd")
                                .setUnitAmount(item.getPrice().movePointRight(2).longValue())
                                .setProductData(
                                        SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                .setName(item.getName())
                                                .addImage(item.getImageUrl())
                                                // 🚨 Crucial Metadata: Link this line item back to the single Order
                                                .putMetadata("order_id", String.valueOf(relatedOrderId))
                                                .build())
                                .build())
                .build();
    }
}