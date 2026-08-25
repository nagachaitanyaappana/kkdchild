package com.example.demo.repository;

import com.example.demo.model.Division;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DivisionRepository extends JpaRepository<Division, Long> {
    Optional<Division> findByName(String name);
    Optional<Division> findByType(String type);
    boolean existsByName(String name);
}
