package com.phaskhmer.st25.spring_boot.dto;

import lombok.Data;

@Data
public class CartItemRequest {
    private Long itemId;
    private int quantity;
}