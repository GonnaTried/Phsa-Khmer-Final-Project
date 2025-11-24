package com.phaskhmer.st25.spring_boot.dto.order;

import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class OrderDTO {
    private long id;
    private long customerId;
    private String customerPhone;
    private LocalDateTime orderDate;
    private OrderStatus status;
    private BigDecimal totalAmount;

    private List<OrderItemDTO> items;

    private String shippingAddressSummary;

}
