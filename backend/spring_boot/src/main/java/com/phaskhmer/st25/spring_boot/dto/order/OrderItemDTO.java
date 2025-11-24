package com.phaskhmer.st25.spring_boot.dto.order;

import java.math.BigDecimal;

import com.phaskhmer.st25.spring_boot.dto.ItemSummaryDTO;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class OrderItemDTO {
    private Long itemId;
    private ItemSummaryDTO item;
    private int quantity;
    private BigDecimal unitPrice;
    private String itemImageUrl;
}
