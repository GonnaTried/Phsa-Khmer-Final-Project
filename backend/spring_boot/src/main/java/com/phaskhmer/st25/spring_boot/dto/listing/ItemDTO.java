package com.phaskhmer.st25.spring_boot.dto.listing;

import lombok.Data;

@Data
public class ItemDTO {
    private Long id;
    private String imageUrl;
    private String name;
    private java.math.BigDecimal price;
}
