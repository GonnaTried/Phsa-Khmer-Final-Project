package com.phaskhmer.st25.spring_boot.controller.payment;

import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PaymentStatusController {

    @Autowired
    private OrderRepository orderRepository; // Use the actual repository

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
        // Assume you add findByStripeSessionId(String) to your OrderRepository
        return orderRepository.findByStripeSessionId(sessionId)
                .map(order -> mapOrderStatusToClientStatus(order.getStatus()))
                .orElse(STATUS_NOT_FOUND);
    }

    // Helper to map internal enum to simple string status for Flutter
    private String mapOrderStatusToClientStatus(OrderStatus internalStatus) {
        return switch (internalStatus) {
            case PAID -> STATUS_SUCCESS;
            case PENDING -> STATUS_PENDING;
            case FAILED, CANCELLED -> STATUS_FAILED;
            default -> STATUS_PENDING; // Treat other statuses as pending fulfillment for now
        };
    }
}