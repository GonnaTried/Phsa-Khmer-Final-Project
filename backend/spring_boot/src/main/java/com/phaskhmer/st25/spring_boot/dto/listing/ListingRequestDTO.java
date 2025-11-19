package com.phaskhmer.st25.spring_boot.dto.listing;

import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ListingRequestDTO {

    @NotBlank(message = "Listing title is required")
    private String title;

    @NotBlank(message = "Listing image URL is required")
    private String image;

    private List<String> tags;

    private ItemRequestDTO itemDetails;

    @NotNull(message = "Category ID is required")
    private Long categoryId;

    @NotNull(message = "Status ID is required")
    private Long statusId;

}
