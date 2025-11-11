package com.phaskhmer.st25.spring_boot.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.phaskhmer.st25.spring_boot.model.Order;
import com.phaskhmer.st25.spring_boot.model.OrderItem;
import com.phaskhmer.st25.spring_boot.model.Product;
import com.phaskhmer.st25.spring_boot.model.SellerEarning;
import com.phaskhmer.st25.spring_boot.repository.OrderItemRepository;
import com.phaskhmer.st25.spring_boot.repository.OrderRepository;
import com.phaskhmer.st25.spring_boot.repository.ProductRepository;
import com.phaskhmer.st25.spring_boot.repository.SellerEarningRepository;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private OrderItemRepository orderItemRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private SellerEarningRepository earningRepository;

    // --- Order Placement (Checkout) ---
    @Transactional
    public Order createOrder(Long buyerId, Long shippingAddressId, List<Long> productIds, List<Integer> quantities) {
        if (productIds.size() != quantities.size()) {
            throw new IllegalArgumentException("Product list and quantity list must match.");
        }

        Order newOrder = new Order();
        newOrder.setBuyerId(buyerId);
        newOrder.setShippingAddressId(shippingAddressId);
        newOrder.setOrderDate(java.time.Instant.now());
        newOrder.setStatus(Order.OrderStatus.PENDING);

        BigDecimal total = BigDecimal.ZERO;
        Order savedOrder = orderRepository.save(newOrder);

        for (int i = 0; i < productIds.size(); i++) {
            Long productId = productIds.get(i);
            Integer quantity = quantities.get(i);

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product not found: " + productId));

            if (product.getStockQuantity() < quantity) {
                throw new RuntimeException("Insufficient stock for product: " + product.getName());
            }

            // 1. Create Order Item 
            OrderItem item = new OrderItem();
            item.setOrderId(savedOrder.getId());
            item.setProductId(productId);
            item.setProductName(product.getName());
            item.setPriceAtPurchase(product.getPrice());
            item.setQuantity(quantity);
            orderItemRepository.save(item);

            // 2. Update Stock
            product.setStockQuantity(product.getStockQuantity() - quantity);
            productRepository.save(product);

            // 3. Calculate Earning
            BigDecimal itemSaleAmount = product.getPrice().multiply(BigDecimal.valueOf(quantity));
            BigDecimal platformFee = itemSaleAmount.multiply(BigDecimal.valueOf(0.10));
            BigDecimal netEarning = itemSaleAmount.subtract(platformFee);

            SellerEarning earning = new SellerEarning();
            earning.setSellerId(product.getSellerId());
            earning.setOrderItemId(item.getId());
            earning.setTransactionDate(java.time.Instant.now());
            earning.setSaleAmount(itemSaleAmount);
            earning.setPlatformFee(platformFee);
            earning.setNetEarning(netEarning);
            earning.setPaymentStatus("PENDING");
            earningRepository.save(earning);

            total = total.add(itemSaleAmount);
        }

        savedOrder.setTotalAmount(total);
        return orderRepository.save(savedOrder);
    }

    // --- Order Retrieval ---
    public List<Order> getOrdersByBuyer(Long buyerId) {
        return orderRepository.findByBuyerId(buyerId);
    }

    // --- Seller Order View (Complex Query) ---
    // --- Fulfillment/Status Update ---
    @Transactional
    public Order updateOrderStatus(Long orderId, Order.OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found."));

        if (order.getStatus() == Order.OrderStatus.SHIPPED && newStatus == Order.OrderStatus.PENDING) {
            throw new IllegalArgumentException("Invalid status transition.");
        }

        order.setStatus(newStatus);
        return orderRepository.save(order);
    }
}
