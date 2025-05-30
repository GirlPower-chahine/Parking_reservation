package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "parking_spots")
@Data
public class ParkingSpot {

    @Id
    private String spotId; // Format: A01, B02, etc.

    @Column(nullable = false)
    private String rowIdentifier; // A, B, C, D, E, F

    @Column(nullable = false)
    private Integer spotNumber; // 1-10

    @Column(nullable = false)
    private Boolean hasElectricCharger;

    @Column(nullable = false)
    private Boolean isAvailable = true;

    // Verrouillage optimiste
    @Version
    private Long version;
}