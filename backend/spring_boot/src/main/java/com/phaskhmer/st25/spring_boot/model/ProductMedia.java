package com.phaskhmer.st25.spring_boot.model;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "product_media")
@Data
@NoArgsConstructor
public class ProductMedia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long productId;

    private String mediaUrl;

    private Boolean isPrimary = false;

    @Enumerated(EnumType.STRING)
    private MediaType mediaType;

    private Integer sortOrder = 0;

    public enum MediaType {
        IMAGE,
        VIDEO
    }
}
