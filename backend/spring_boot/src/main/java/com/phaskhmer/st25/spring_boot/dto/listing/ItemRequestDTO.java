package com.phaskhmer.st25.spring_boot.dto.listing;

import java.math.BigDecimal;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ItemRequestDTO {

    @NotBlank(message = "Image URL is required")
    private String imageUrl;

    @NotBlank(message = "Name is required")
    private String name;

    @NotNull(message = "Price is required")
    private BigDecimal price;
}