package com.phaskhmer.st25.spring_boot.controller;
import com.phaskhmer.st25.spring_boot.model.listing.Listing;
import com.phaskhmer.st25.spring_boot.service.listing.ListingService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/listings")
public class ListingController {

    private final ListingService listingService;

    public ListingController(ListingService listingService) {
        this.listingService = listingService;
    }

    @GetMapping("/search")
    public List<Listing> searchListingsByName(@RequestParam("name") String name) {
        return listingService.getListingsByName(name);
    }
}