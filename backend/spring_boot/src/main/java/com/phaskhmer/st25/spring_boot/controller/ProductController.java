package com.phaskhmer.st25.spring_boot.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.phaskhmer.st25.spring_boot.model.Product;
import com.phaskhmer.st25.spring_boot.model.ProductMedia;
import com.phaskhmer.st25.spring_boot.service.ProductService;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    // --- Utility Method for JWT Principal Extraction ---
    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            try {
                return Long.parseLong(authentication.getName());
            } catch (NumberFormatException e) {
                throw new IllegalStateException("Authenticated principal is not a valid User ID.");
            }
        }
        throw new IllegalStateException("User not authenticated.");
    }

    // ------------------------------------------------------------------
    // PUBLIC ACCESS ENDPOINTS
    // ------------------------------------------------------------------
    @GetMapping
    public List<Product> getAllProducts() {
        return productService.getAllAvailableProducts();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {

        Optional<Product> productOpt = productService.getProductById(id);

        if (productOpt.isEmpty() || !productOpt.get().getIsAvailable()) {

            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(productOpt.get());
    }

    // ------------------------------------------------------------------
    // SELLER MANAGEMENT ENDPOINTS
    // ------------------------------------------------------------------
    @GetMapping("/my-listings")
    public List<Product> getMyListings() {
        Long sellerId = getCurrentUserId();
        return productService.getProductsBySeller(sellerId);
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        Long sellerId = getCurrentUserId();
        Product createdProduct = productService.createProduct(product, sellerId);
        return new ResponseEntity<>(createdProduct, HttpStatus.CREATED);
    }

    // --- CORRECTION APPLIED HERE (The generic type mismatch error) ---
    @PutMapping("/{id}")
    public ResponseEntity<?> updateProduct(@PathVariable Long id, @RequestBody Product productDetails) {
        try {
            Long sellerId = getCurrentUserId();
            Product updatedProduct = productService.updateProduct(id, productDetails, sellerId);
            return ResponseEntity.ok(updatedProduct);
        } catch (SecurityException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.FORBIDDEN);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // --- CORRECTION APPLIED HERE (The raw type and generic mismatch error) ---
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProduct(@PathVariable Long id) {
        try {
            Long sellerId = getCurrentUserId();
            productService.deleteProduct(id, sellerId);
            return ResponseEntity.noContent().build();
        } catch (SecurityException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.FORBIDDEN);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/media")
    public List<ProductMedia> getProductMedia(@PathVariable Long id) {
        return productService.getMediaForProduct(id);
    }

    @PostMapping("/{id}/media")
    public ResponseEntity<ProductMedia> addProductMedia(@PathVariable Long id, @RequestBody ProductMedia media) {

        try {
            ProductMedia newMedia = productService.addMediaToProduct(id, media);
            return new ResponseEntity<>(newMedia, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity("Failed to add media: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/media/{mediaId}")
    public ResponseEntity<Void> deleteProductMedia(@PathVariable Long mediaId) {
        productService.deleteMedia(mediaId);
        return ResponseEntity.noContent().build();
    }
}
