package com.phaskhmer.st25.spring_boot.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "shipping_addresses")
@Data
public class ShippingAddress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long customerId;

    private String recipientName;
    private String streetAddress;
    private String city;
    private String province;
    private String zipCode;
    private String country;

    private Boolean isDefault = false;
}
