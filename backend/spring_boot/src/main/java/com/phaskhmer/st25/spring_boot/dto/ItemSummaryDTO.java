package com.phaskhmer.st25.spring_boot.dto;

import java.math.BigDecimal;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ItemSummaryDTO {
    private Long id;
    private String name;
    private String imageUrl;
    private BigDecimal price;

}
