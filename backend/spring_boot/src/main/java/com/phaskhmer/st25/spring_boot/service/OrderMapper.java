// src/main/java/com/phaskhmer/st25/spring_boot/service/OrderMapper.java
package com.phaskhmer.st25.spring_boot.service;

import com.phaskhmer.st25.spring_boot.dto.ItemSummaryDTO;
import com.phaskhmer.st25.spring_boot.dto.order.OrderDTO;
import com.phaskhmer.st25.spring_boot.dto.order.OrderItemDTO;
import com.phaskhmer.st25.spring_boot.model.order.Order;
import com.phaskhmer.st25.spring_boot.model.order.OrderItem;
import com.phaskhmer.st25.spring_boot.model.order.OrderStatus;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

import java.util.List;
import java.util.stream.Collectors;
@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public class OrderMapper {

    /**
     * Converts a single Order entity to an OrderDTO.
     */
    @Mapping(target = "customerId", source = "customer.id")
    public static OrderDTO toDto(Order order) {
        if (order == null) {
            return null;
        }

        List<OrderItemDTO> itemDtos = order.getItems().stream()
                .map(OrderMapper::toOrderItemDto)
                .collect(Collectors.toList());
        String addressSummary = order.getShippingAddress() != null
                ? order.getShippingAddress().getProvince() + ", " + order.getShippingAddress().getCity() + ", " + order.getShippingAddress().getStreetAddress()
                : "N/A";


        return OrderDTO.builder()
                .id(order.getId())
                .customerId(order.getCustomer().getId())
                .orderDate(order.getOrderDate())
                .status(order.getStatus())
                .totalAmount(order.getTotalAmount())
                .items(itemDtos)
                .shippingAddressSummary(addressSummary)
                .build();
    }

    /**
     * Converts a list of Order entities to a list of OrderDTOs.
     */
    public static List<OrderDTO> toDtoList(List<Order> orders) {
        return orders.stream()
                .map(OrderMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Converts an OrderItem entity to an OrderItemDTO.
     */
    private static OrderItemDTO toOrderItemDto(OrderItem orderItem) {
        if (orderItem == null) {
            return null;
        }

        // Map the associated Item to a simplified summary DTO
        ItemSummaryDTO itemDto = ItemSummaryDTO.builder()
                .id(orderItem.getItem().getId())
                .name(orderItem.getItem().getName())
                .price(orderItem.getUnitPrice())
                .imageUrl(orderItem.getItem().getImageUrl())
                .build();

        return OrderItemDTO.builder()
                .itemId(orderItem.getId())
                .item(itemDto)
                .quantity(orderItem.getQuantity())
                .unitPrice(orderItem.getUnitPrice())
                .build();
    }
}