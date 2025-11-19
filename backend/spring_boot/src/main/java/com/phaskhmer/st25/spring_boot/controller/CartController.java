package com.phaskhmer.st25.spring_boot.controller;

import com.phaskhmer.st25.spring_boot.dto.CartItemRequest;
import com.phaskhmer.st25.spring_boot.model.cart.Cart;
import com.phaskhmer.st25.spring_boot.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.userdetails.UserDetails;


@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    // Helper to get the current user's ID from security context
    private Long getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String userIdString;
        if (principal instanceof UserDetails) {
            userIdString = ((UserDetails) principal).getUsername();
        } else {
            userIdString = principal.toString();
        }
        return Long.valueOf(userIdString);
    }

    @GetMapping
    public ResponseEntity<Cart> getMyCart() {
        Long customerId = getCurrentUserId();
        Cart cart = cartService.getOrCreateCart(customerId);
        return ResponseEntity.ok(cart);
    }

    @PostMapping("/items")
    public ResponseEntity<Cart> addItemToMyCart(@RequestBody CartItemRequest request) {
        Long customerId = getCurrentUserId();
        Cart updatedCart = cartService.addItemToCart(customerId, request.getItemId(), request.getQuantity());
        return ResponseEntity.ok(updatedCart);
    }

    @PutMapping("/items/{itemId}")
    public ResponseEntity<Cart> updateItemInMyCart(@PathVariable Long itemId, @RequestBody CartItemRequest request) {
        Long customerId = getCurrentUserId();
        Cart updatedCart = cartService.updateItemQuantity(customerId, itemId, request.getQuantity());
        return ResponseEntity.ok(updatedCart);
    }

    @DeleteMapping("/items/{itemId}")
    public ResponseEntity<Cart> removeItemFromMyCart(@PathVariable Long itemId) {
        Long customerId = getCurrentUserId();
        Cart updatedCart = cartService.removeItemFromCart(customerId, itemId);
        return ResponseEntity.ok(updatedCart);
    }
}