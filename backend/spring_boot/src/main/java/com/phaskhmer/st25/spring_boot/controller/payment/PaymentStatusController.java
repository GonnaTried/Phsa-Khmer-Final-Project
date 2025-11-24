package com.phaskhmer.st25.spring_boot.controller.payment;

import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class PaymentStatusController {

    @Autowired
    private OrderRepository orderRepository;

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_SUCCESS = "SUCCESS"; // Map to PAID
    public static final String STATUS_FAILED = "FAILED";
    public static final String STATUS_NOT_FOUND = "NOT_FOUND";

    // Simple DTO for the response
    public static class PaymentStatusResponse {
        public final String sessionId;
        public final String status;

        public PaymentStatusResponse(String sessionId, String status) {
            this.sessionId = sessionId;
            this.status = status;
        }
    }

    /**
     * Flutter polls this endpoint to check the status of the payment.
     */
    @GetMapping("/api/payment/status")
    public ResponseEntity<PaymentStatusResponse> checkPaymentStatus(
            @RequestParam("session_id") String sessionId) {

        String currentStatus = lookUpOrderStatus(sessionId);

        return ResponseEntity.ok(new PaymentStatusResponse(sessionId, currentStatus));
    }

    private String lookUpOrderStatus(String sessionId) {

        // 1. Retrieve all orders associated with this Stripe Session ID
        List<Order> orders = orderRepository.findByStripeSessionId(sessionId);

        if (orders.isEmpty()) {
            return STATUS_NOT_FOUND;
        }

        // 2. Check the combined status of all orders

        boolean allPaid = orders.stream()
                .allMatch(order -> order.getStatus() == OrderStatus.PAID);

        boolean anyFailedOrCancelled = orders.stream()
                .anyMatch(order -> order.getStatus() == OrderStatus.FAILED || order.getStatus() == OrderStatus.CANCELLED);

        // 3. Determine the final status for the client
        if (allPaid) {
            return STATUS_SUCCESS;
        } else if (anyFailedOrCancelled) {
            // If any associated order failed or was cancelled, report failure.
            return STATUS_FAILED;
        } else {
            // If orders exist but not all are PAID, they must be PENDING/PROCESSING.
            return STATUS_PENDING;
        }
    }
}