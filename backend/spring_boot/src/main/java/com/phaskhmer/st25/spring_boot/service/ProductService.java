package com.phaskhmer.st25.spring_boot.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.phaskhmer.st25.spring_boot.model.Product;
import com.phaskhmer.st25.spring_boot.model.ProductHistory;
import com.phaskhmer.st25.spring_boot.model.ProductMedia;
import com.phaskhmer.st25.spring_boot.repository.ProductHistoryRepository;
import com.phaskhmer.st25.spring_boot.repository.ProductMediaRepository;
import com.phaskhmer.st25.spring_boot.repository.ProductRepository;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductHistoryRepository productHistoryRepository;

    @Autowired
    private ProductMediaRepository mediaRepository;

    // --- Public Product Retrieval ---
    public List<Product> getAllAvailableProducts() {
        return productRepository.findAll().stream()
                .filter(Product::getIsAvailable)
                .toList();
    }

    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }

    // --- Seller Actions ---
    public List<Product> getProductsBySeller(Long sellerId) {
        return productRepository.findBySellerId(sellerId);
    }

    @Transactional
    public Product createProduct(Product product, Long sellerId) {
        product.setSellerId(sellerId);

        Product savedProduct = productRepository.save(product);

        ProductHistory initialHistory = new ProductHistory(savedProduct, sellerId);
        productHistoryRepository.save(initialHistory);

        return savedProduct;
    }

    @Transactional
    public Product updateProduct(Long productId, Product productDetails, Long currentSellerId) {
        Product existingProduct = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found."));

        if (!existingProduct.getSellerId().equals(currentSellerId)) {
            throw new SecurityException("Unauthorized access: Seller ID mismatch.");
        }

        boolean priceChanged = !existingProduct.getPrice().equals(productDetails.getPrice());
        boolean stockChanged = !existingProduct.getStockQuantity().equals(productDetails.getStockQuantity());

        existingProduct.setName(productDetails.getName());
        existingProduct.setDescription(productDetails.getDescription());
        existingProduct.setPrice(productDetails.getPrice());
        existingProduct.setStockQuantity(productDetails.getStockQuantity());
        existingProduct.setIsAvailable(productDetails.getIsAvailable());

        Product updatedProduct = productRepository.save(existingProduct);

        if (priceChanged || stockChanged) {
            ProductHistory history = new ProductHistory(updatedProduct, currentSellerId);
            productHistoryRepository.save(history);
        }

        return updatedProduct;
    }

    @Transactional
    public void deleteProduct(Long productId, Long currentSellerId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found."));

        if (!product.getSellerId().equals(currentSellerId)) {
            throw new SecurityException("Unauthorized access to delete product.");
        }

        productRepository.delete(product);
    }

    @Transactional
    public ProductMedia addMediaToProduct(Long productId, ProductMedia media) {
        productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found."));

        // Set the foreign key
        media.setProductId(productId);

        // If setting a new primary image, unset the old one (basic logic)
        if (media.getIsPrimary() != null && media.getIsPrimary()) {
            mediaRepository.findByProductIdAndIsPrimaryTrue(productId)
                    .ifPresent(oldPrimary -> {
                        oldPrimary.setIsPrimary(false);
                        mediaRepository.save(oldPrimary);
                    });
        }

        return mediaRepository.save(media);
    }

    public List<ProductMedia> getMediaForProduct(Long productId) {
        return mediaRepository.findByProductIdOrderBySortOrderAsc(productId);
    }

    @Transactional
    public void deleteMedia(Long mediaId) {
        mediaRepository.deleteById(mediaId);
    }
}
