package com.phaskhmer.st25.spring_boot.controller.seller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping; // Added GetMapping
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phaskhmer.st25.spring_boot.dto.listing.ItemMetadataDTO;
import com.phaskhmer.st25.spring_boot.model.Item;
import com.phaskhmer.st25.spring_boot.model.Listing;
import com.phaskhmer.st25.spring_boot.service.listing.ListingService;
import com.phaskhmer.st25.spring_boot.service.storage.FileStorageService;
import lombok.RequiredArgsConstructor;

@RestController
// Base path is for listings owned by the authenticated seller
@RequestMapping("/api/seller/listings")
@RequiredArgsConstructor // Automatically creates the constructor for final fields
public class SellerListingController {

    private final FileStorageService fileStorageService;
    private final ListingService listingService;
    private final ObjectMapper objectMapper;

    /**
     * Helper method to extract the principal ID (Customer ID) from the Security Context.
     */
    private Long getCurrentSellerId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("User is not authenticated.");
        }

        // Try to retrieve the principal as the UserDetails object
        Object principal = authentication.getPrincipal();

        String principalIdString;

        if (principal instanceof UserDetails) {
            // Correctly extract the username (which is your seller ID string)
            principalIdString = ((UserDetails) principal).getUsername();
        } else {
            // Fallback for simple String principal (less common with UserDetails setup)
            principalIdString = principal.toString();
        }

        try {
            // Ensure there's no whitespace or non-numeric characters
            return Long.valueOf(principalIdString.trim());
        } catch (NumberFormatException e) {
            // Log the problematic string to debug further
            System.err.println("Attempted to parse ID: '" + principalIdString + "'");
            throw new IllegalArgumentException("Invalid principal ID format in token: " + principalIdString, e);
        }
    }

    // =================================================================
    // GET: Fetch Listings for the current Seller
    // =================================================================

    /**
     * Endpoint to fetch all listings for the currently authenticated seller.
     * Request: GET /api/seller/listings
     */
    @GetMapping
    public ResponseEntity<List<Listing>> getMyListings() {
        Long sellerId = getCurrentSellerId();

        List<Listing> listings = listingService.getListingsBySeller(sellerId);

        if (listings.isEmpty()) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.ok(listings);
    }

    // =================================================================
    // POST: Create a new Listing
    // =================================================================

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> postFullListing(
            @RequestParam("title") String listingTitle,
            @RequestParam("item_count") int itemCount,
            @RequestParam(name="category_id", required = false) Long categoryId,
            @RequestPart("listing_thumbnail") MultipartFile listingThumbnail,
            @RequestPart("item_images") List<MultipartFile> itemImages,
            @RequestParam("item_details") String itemDetailsJson,
            @RequestParam("statusId") Long statusId
    ) {
        if (itemImages.size() != itemCount) {
            return new ResponseEntity<>("Item image count mismatch.", HttpStatus.BAD_REQUEST);
        }

        String savedThumbnailName = null;
        List<String> savedItemImageNames = new ArrayList<>();
        Long sellerId = getCurrentSellerId();
        System.out.println("DEBUG: Seller ID extracted from JWT: " + sellerId);

        try {
            // A. Store Listing Thumbnail
            savedThumbnailName = fileStorageService.storeFile(listingThumbnail);

            // B. Store Item Images
            for (MultipartFile imageFile : itemImages) {
                String savedFileName = fileStorageService.storeFile(imageFile);
                savedItemImageNames.add(savedFileName);
            }

            // C. Parse the Item Details JSON String
            List<ItemMetadataDTO> itemMetadata = objectMapper.readValue(
                    itemDetailsJson,
                    new TypeReference<List<ItemMetadataDTO>>() {}
            );

            if (itemMetadata.size() != itemCount) {
                return new ResponseEntity<>("Item metadata count mismatch.", HttpStatus.BAD_REQUEST);
            }

            // D. Combine Metadata and File Paths into Final Item Models
            List<Item> finalItems = new ArrayList<>();
            for (int i = 0; i < itemMetadata.size(); i++) {
                ItemMetadataDTO metadata = itemMetadata.get(i);

                Item finalItem = Item.builder()
                        .name(metadata.getName())
                        .price(metadata.getPrice())
                        .imageUrl(savedItemImageNames.get(i))
                        .build();

                finalItems.add(finalItem);
            }

            // E. Call the Service to persist the Listing and Items
            Listing createdListing = listingService.createFullListing(
                    sellerId,
                    listingTitle,
                    savedThumbnailName,
                    finalItems,
                    categoryId,
                    statusId
            );

            // F. Return the created Listing object
            return new ResponseEntity<>(createdListing, HttpStatus.CREATED);

        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (IOException e) {
            System.err.println("Error parsing JSON or handling files: " + e.getMessage());
            return new ResponseEntity<>("Internal server error during processing.", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}