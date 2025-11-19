package com.phaskhmer.st25.spring_boot.service.listing;

// ... imports ...
import java.util.List;
import java.util.Optional;

import com.phaskhmer.st25.spring_boot.model.Customer;
import com.phaskhmer.st25.spring_boot.repository.CustomerRepository;
import com.phaskhmer.st25.spring_boot.service.CustomerService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.phaskhmer.st25.spring_boot.model.Category;
import com.phaskhmer.st25.spring_boot.model.listing.Item;
import com.phaskhmer.st25.spring_boot.model.listing.Listing;
import com.phaskhmer.st25.spring_boot.model.listing.ListingStatus;
import com.phaskhmer.st25.spring_boot.repository.CategoryRepository;
import com.phaskhmer.st25.spring_boot.repository.ListingRepository;
import com.phaskhmer.st25.spring_boot.repository.ListingStatusRepository;

@Service
public class ListingService {

    private final ListingRepository listingRepository;
    private final CategoryRepository categoryRepository; 
    private final ListingStatusRepository listingStatusRepository;
    private final CustomerRepository customerRepository;
    private final CustomerService customerService;



    // Inject repositories
    public ListingService(ListingRepository listingRepository, CategoryRepository categoryRepository, ListingStatusRepository listingStatusRepository, CustomerRepository customerRepository, CustomerService customerService) {
        this.listingRepository = listingRepository;
        this.categoryRepository = categoryRepository;
        this.listingStatusRepository = listingStatusRepository;
        this.customerRepository = customerRepository;
        this.customerService = customerService;
    }

    // Replace the simulated lookup with repository lookup
    private Category findCategoryById(Long id) {
        // Use the repository method (adjust based on your actual Category model/repository)
        return categoryRepository.findById(id).orElse(null);
    }

    private ListingStatus findListingStatusById(Long id) {
        return listingStatusRepository.findById(id).orElse(null);
    }





    // ... (omitted the old in-memory method) ...
    public Listing createFullListing(
            Long sellerId,
            String title,
            String thumbnailPath,
            List<Item> items,
            Long categoryId,
            Long statusID
    ) {
        Customer seller = customerService.getSeller(sellerId);

        Category category = null;
        if (categoryId != null) {
            category = findCategoryById(categoryId);
            if (category == null) {
                throw new IllegalArgumentException("Category ID provided but not found: " + categoryId);
            }
        }

        ListingStatus status = null;
        statusID = 1l;
        if (statusID != null) {
            status = findListingStatusById(statusID);
            if (status == null) {
                throw new IllegalArgumentException("Status ID provided but not found: " + statusID);
            }
        }


        // 1. Create the Listing Model
        Listing newListing = Listing.builder()
                .seller(seller)
                .title(title)
                .image(thumbnailPath)
                .category(category)
                .items(items)
                .status(status)
                .build();
            
        // 2. IMPORTANT: Set the bidirectional relationship (FK linkage)
        for (Item item : items) {
            item.setListing(newListing);
        }

        // 3. Persist the Listing (which cascades and saves the Items)
        return listingRepository.save(newListing);
    }

    public Page<Listing> getPublicListings(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("id").descending());

        return listingRepository.findAll(pageable);
    }

    public Optional<Listing> getPublicListingById(Integer id) {
        return listingRepository.findById(id.longValue());
    }

    public List<Listing> getAllListings() {
        return listingRepository.findAll();
    }
    public List<Listing> getListingsBySeller(Long sellerId) {
        return listingRepository.findBySellerId(sellerId);
    }
}
