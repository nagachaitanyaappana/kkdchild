package com.example.demo.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "division")
public class Division {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 50, unique = true)
    private String code;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private DivisionType type;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "division", cascade = CascadeType.ALL)
    private List<Locality> localities = new ArrayList<>();

    public Division() {}

    public Division(String name, DivisionType type) {
        this.name = name;
        this.type = type;
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public DivisionType getType() { return type; }
    public void setType(DivisionType type) { this.type = type; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<Locality> getLocalities() { return localities; }
    public void setLocalities(List<Locality> localities) { this.localities = localities; }
}
