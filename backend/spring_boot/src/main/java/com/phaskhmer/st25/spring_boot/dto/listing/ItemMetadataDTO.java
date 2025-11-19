package com.phaskhmer.st25.spring_boot.dto.listing;

import java.math.BigDecimal;

import lombok.Data;

@Data
public class ItemMetadataDTO {
    private String name;
    private BigDecimal price;
}