package com.phaskhmer.st25.spring_boot.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.phaskhmer.st25.spring_boot.model.ListingStatus;
import com.phaskhmer.st25.spring_boot.repository.ListingStatusRepository;

@Configuration
public class DataInitializer {

    @Bean
    public CommandLineRunner initStatuses(ListingStatusRepository statusRepository) {
        return args -> {
            if (statusRepository.count() == 0) {
                statusRepository.save(new ListingStatus(null, "active", "Listing is visible and tradable."));
                statusRepository.save(new ListingStatus(null, "reviewing", "Listing is pending manual verification."));
                statusRepository.save(new ListingStatus(null, "archived", "Listing has been voluntarily hidden by seller."));
                statusRepository.save(new ListingStatus(null, "banned", "Listing has been removed due to policy violation."));
                System.out.println("Initialized 4 Listing Statuses.");
            }
        };
    }
}