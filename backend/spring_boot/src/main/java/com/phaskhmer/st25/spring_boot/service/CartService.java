package com.phaskhmer.st25.spring_boot.service;

import com.phaskhmer.st25.spring_boot.model.Customer;
import com.phaskhmer.st25.spring_boot.model.cart.Cart;
import com.phaskhmer.st25.spring_boot.model.cart.CartItem;
import com.phaskhmer.st25.spring_boot.model.listing.Item;
import com.phaskhmer.st25.spring_boot.repository.CartItemRepository;
import com.phaskhmer.st25.spring_boot.repository.CartRepository;
import com.phaskhmer.st25.spring_boot.repository.CustomerRepository;
import com.phaskhmer.st25.spring_boot.repository.ItemRepository; // You will need an ItemRepository
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Transactional
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final CustomerRepository customerRepository;
    private final ItemRepository itemRepository;

    // Gets the current user's cart, or creates one if it doesn't exist.
    public Cart getOrCreateCart(Long customerId) {
        return cartRepository.findByCustomerId(customerId).orElseGet(() -> {
            Customer customer = customerRepository.findById(customerId)
                    .orElseThrow(() -> new RuntimeException("Customer not found"));
            Cart newCart = new Cart();
            newCart.setCustomer(customer);
            return cartRepository.save(newCart);
        });
    }

    public Cart addItemToCart(Long customerId, Long itemId, int quantity) {
        Cart cart = getOrCreateCart(customerId);
        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Item not found"));

        // Check if item is already in cart
        cartItemRepository.findByCartIdAndItemId(cart.getId(), itemId)
                .ifPresentOrElse(
                        // If present, update quantity
                        cartItem -> {
                            cartItem.setQuantity(cartItem.getQuantity() + quantity);
                            cartItemRepository.save(cartItem);
                        },
                        // If not present, create a new cart item
                        () -> {
                            CartItem newCartItem = new CartItem();
                            newCartItem.setCart(cart);
                            newCartItem.setItem(item);
                            newCartItem.setQuantity(quantity);
                            cart.getItems().add(newCartItem); // Add to the list in the Cart object
                            cartRepository.save(cart); // Persist through the cart
                        }
                );
        return getOrCreateCart(customerId); // Return the updated cart
    }

    public Cart removeItemFromCart(Long customerId, Long itemId) {
        Cart cart = getOrCreateCart(customerId);
        CartItem cartItem = cartItemRepository.findByCartIdAndItemId(cart.getId(), itemId)
                .orElseThrow(() -> new RuntimeException("Item not found in cart"));

        cartItemRepository.delete(cartItem);
        return getOrCreateCart(customerId);
    }

    public Cart updateItemQuantity(Long customerId, Long itemId, int quantity) {
        if (quantity <= 0) {
            return removeItemFromCart(customerId, itemId);
        }

        Cart cart = getOrCreateCart(customerId);
        CartItem cartItem = cartItemRepository.findByCartIdAndItemId(cart.getId(), itemId)
                .orElseThrow(() -> new RuntimeException("Item not found in cart"));

        cartItem.setQuantity(quantity);
        cartItemRepository.save(cartItem);
        return getOrCreateCart(customerId);
    }

    public BigDecimal calculateCartTotal(Long customerId) {
        Cart cart = cartRepository.findByCustomerId(customerId)
                .orElseThrow(() -> new RuntimeException("Cart not found for customer ID: " + customerId));

        return cart.getItems().stream()
                .map(item -> item.getItem().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}