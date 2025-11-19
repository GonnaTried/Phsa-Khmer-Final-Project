package com.phaskhmer.st25.spring_boot.service;

import com.phaskhmer.st25.spring_boot.model.Customer;
import com.phaskhmer.st25.spring_boot.model.ShippingAddress;
import com.phaskhmer.st25.spring_boot.repository.CustomerRepository;
import com.phaskhmer.st25.spring_boot.repository.ShippingAddressRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final ShippingAddressRepository addressRepository;

    public CustomerService(CustomerRepository customerRepository, ShippingAddressRepository addressRepository) {
        this.customerRepository = customerRepository;
        this.addressRepository = addressRepository;
    }

    @Transactional
    public Customer ensureCustomerExists(Long userId) {
        return customerRepository.findById(userId).orElseGet(() -> {
            Customer newCustomer = new Customer();
            newCustomer.setId(userId);
            newCustomer.setPhone(null);
            newCustomer.setIsSeller(false);

            return customerRepository.save(newCustomer);
        });
    }

    // --- Shipping Address CRUD ---
    public List<ShippingAddress> getAddressesByCustomer(Long customerId) {
        return addressRepository.findByCustomerId(customerId);
    }

    @Transactional
    public ShippingAddress saveAddress(Long customerId, ShippingAddress address) {
        if (address.getIsDefault()) {
            addressRepository.findByCustomerIdAndIsDefaultTrue(customerId)
                    .ifPresent(oldDefault -> {
                        oldDefault.setIsDefault(false);
                        addressRepository.save(oldDefault);
                    });
        }

        address.setCustomerId(customerId);
        return addressRepository.save(address);
    }

    @Transactional
    public void deleteAddress(Long customerId, Long addressId) {
        ShippingAddress address = addressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found."));

        if (!address.getCustomerId().equals(customerId)) {
            throw new SecurityException("Unauthorized access to address.");
        }
        addressRepository.delete(address);
    }

    public Customer getSeller(Long sellerId) {
        return ensureCustomerExists(sellerId);
    }
}
