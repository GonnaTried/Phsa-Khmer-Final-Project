package com.phaskhmer.st25.spring_boot.dto.order;

import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class OrderStatusUpdateDTO {
    @NotNull(message = "New status must be provided")
    private OrderStatus newStatus;
}