package com.phaskhmer.st25.spring_boot.service;

public interface PaymentService {
    void updateOrderStatus(String sessionId, String status);
    String getOrderStatus(String sessionId);
}
