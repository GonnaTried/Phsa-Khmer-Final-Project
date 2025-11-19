package com.phaskhmer.st25.spring_boot.controller;

import com.phaskhmer.st25.spring_boot.model.ShippingAddress;
import com.phaskhmer.st25.spring_boot.service.ShippingAddressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers/{customerId}/addresses")
public class ShippingAddressController {

    @Autowired
    private ShippingAddressService shippingAddressService;

    @GetMapping
    public List<ShippingAddress> getAddressesByCustomerId(@PathVariable Long customerId) {
        return shippingAddressService.getAddressesByCustomerId(customerId);
    }

    @PostMapping
    public ResponseEntity<ShippingAddress> createAddress(@PathVariable Long customerId, @RequestBody ShippingAddress shippingAddress) {
        shippingAddress.setCustomerId(customerId);
        ShippingAddress createdAddress = shippingAddressService.createAddress(shippingAddress);
        return new ResponseEntity<>(createdAddress, HttpStatus.CREATED);
    }

    @GetMapping("/{addressId}")
    public ResponseEntity<ShippingAddress> getAddressById(@PathVariable Long addressId) {
        return shippingAddressService.getAddressById(addressId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{addressId}")
    public ResponseEntity<ShippingAddress> updateAddress(@PathVariable Long addressId, @RequestBody ShippingAddress addressDetails) {
        return shippingAddressService.updateAddress(addressId, addressDetails)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{addressId}")
    public ResponseEntity<Void> deleteAddress(@PathVariable Long addressId) {
        if (shippingAddressService.deleteAddress(addressId)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/{addressId}/set-default")
    public ResponseEntity<Void> setDefaultAddress(@PathVariable Long customerId, @PathVariable Long addressId) {
        shippingAddressService.setDefaultAddress(customerId, addressId);
        return ResponseEntity.ok().build();
    }
}
