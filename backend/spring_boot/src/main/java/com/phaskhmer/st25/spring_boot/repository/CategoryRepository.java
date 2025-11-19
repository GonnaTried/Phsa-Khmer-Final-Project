package com.phaskhmer.st25.spring_boot.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.phaskhmer.st25.spring_boot.model.Category;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    
}

    
