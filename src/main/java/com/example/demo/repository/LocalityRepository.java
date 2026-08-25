package com.example.demo.repository;

import com.example.demo.model.Locality;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LocalityRepository extends JpaRepository<Locality, Long> {
    Optional<Locality> findByName(String name);
}
