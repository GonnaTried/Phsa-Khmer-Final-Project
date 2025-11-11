package com.phaskhmer.st25.spring_boot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.phaskhmer.st25.spring_boot.model.Customer;
import com.phaskhmer.st25.spring_boot.model.ShippingAddress;
import com.phaskhmer.st25.spring_boot.service.CustomerService;

@RestController
@RequestMapping("/api/customer")
public class CustomerController {

    @Autowired
    private CustomerService customerService;

    private Long getCurrentUserId() {

        return Long.parseLong(org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getName());
    }

    // --- Customer Profile Setup ---
    @GetMapping("/profile/ensure")
    public ResponseEntity<Customer> ensureProfile() {
        Long userId = getCurrentUserId();
        Customer customer = customerService.ensureCustomerExists(userId);
        return ResponseEntity.ok(customer);
    }

    // --- Shipping Address Management ---
    @GetMapping("/addresses")
    public List<ShippingAddress> getMyAddresses() {
        Long customerId = getCurrentUserId();
        return customerService.getAddressesByCustomer(customerId);
    }

    @PostMapping("/addresses")
    public ResponseEntity<ShippingAddress> addAddress(@RequestBody ShippingAddress address) {
        Long customerId = getCurrentUserId();
        ShippingAddress savedAddress = customerService.saveAddress(customerId, address);
        return new ResponseEntity<>(savedAddress, HttpStatus.CREATED);
    }

    @DeleteMapping("/addresses/{id}")
    public ResponseEntity<Void> deleteAddress(@PathVariable Long id) {
        try {
            Long customerId = getCurrentUserId();
            customerService.deleteAddress(customerId, id);
            return ResponseEntity.noContent().build();
        } catch (SecurityException e) {
            return new ResponseEntity(e.getMessage(), HttpStatus.FORBIDDEN);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
