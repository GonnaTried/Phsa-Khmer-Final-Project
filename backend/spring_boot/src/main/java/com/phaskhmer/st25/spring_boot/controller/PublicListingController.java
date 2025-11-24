package com.phaskhmer.st25.spring_boot.controller;

import com.phaskhmer.st25.spring_boot.model.listing.Listing;
import com.phaskhmer.st25.spring_boot.service.listing.ListingService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
@RequestMapping("/api/public/listings")
@RequiredArgsConstructor
public class PublicListingController {

    private final ListingService listingService;

    /**
     * Endpoint to fetch all listings with pagination and sorting (newest first).
     *
     * Example Requests:
     * GET /api/public/listings -> Gets the first page (10 items)
     * GET /api/public/listings?page=0&size=20 -> Gets the first page with 20 items
     * GET /api/public/listings?page=1&size=15 -> Gets the second page with 15 items
     *
     * @param page The page number requested (defaults to 0).
     * @param size The number of items per page (defaults to 10).
     * @return A ResponseEntity containing a Page of Listing objects.
     */
    @GetMapping
    public ResponseEntity<Page<Listing>> getAllListings(
            @RequestParam(name = "page", defaultValue = "0") int page,
            @RequestParam(name = "size", defaultValue = "10") int size
    ) {
        Page<Listing> listingsPage = listingService.getPublicListings(page, size);
        return ResponseEntity.ok(listingsPage);
    }

    /**
     * Endpoint to fetch a single listing by its ID.
     *
     * Example Request:
     * GET /api/public/listings/1
     *
     * @param id The ID of the listing to retrieve.
     * @return A ResponseEntity containing the Listing object if found, or 404 Not Found.
     */
    @GetMapping("/{id}")
    public ResponseEntity<Listing> getListingById(@PathVariable Integer id) {
        Optional<Listing> listing = listingService.getPublicListingById(id);
        return listing.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    
}