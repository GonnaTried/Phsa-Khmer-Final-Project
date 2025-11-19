package com.phaskhmer.st25.spring_boot.dto.payway;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class PayWayItem {
    private String name;
    private int quantity;
    private BigDecimal price;
    private String sku;
}