package com.phaskhmer.st25.spring_boot.service;

import com.phaskhmer.st25.spring_boot.model.ShippingAddress;
import com.phaskhmer.st25.spring_boot.repository.ShippingAddressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class ShippingAddressService {

    @Autowired
    private ShippingAddressRepository shippingAddressRepository;

    public List<ShippingAddress> getAddressesByCustomerId(Long customerId) {
        return shippingAddressRepository.findByCustomerId(customerId);
    }

    public Optional<ShippingAddress> getAddressById(Long id) {
        return shippingAddressRepository.findById(id);
    }

    public ShippingAddress createAddress(ShippingAddress shippingAddress) {
        return shippingAddressRepository.save(shippingAddress);
    }

    public Optional<ShippingAddress> updateAddress(Long id, ShippingAddress addressDetails) {
        return shippingAddressRepository.findById(id)
                .map(existingAddress -> {
                    existingAddress.setRecipientName(addressDetails.getRecipientName());
                    existingAddress.setStreetAddress(addressDetails.getStreetAddress());
                    existingAddress.setCity(addressDetails.getCity());
                    existingAddress.setProvince(addressDetails.getProvince());
                    existingAddress.setZipCode(addressDetails.getZipCode());
                    existingAddress.setCountry(addressDetails.getCountry());
                    existingAddress.setIsDefault(addressDetails.getIsDefault());
                    return shippingAddressRepository.save(existingAddress);
                });
    }

    public boolean deleteAddress(Long id) {
        if (shippingAddressRepository.existsById(id)) {
            shippingAddressRepository.deleteById(id);
            return true;
        }
        return false;
    }

    @Transactional
    public void setDefaultAddress(Long customerId, Long addressId) {
        shippingAddressRepository.findByCustomerId(customerId).forEach(address -> {
            address.setIsDefault(address.getId().equals(addressId));
            shippingAddressRepository.save(address);
        });
    }
}
