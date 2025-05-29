package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "PARKING_SPOTS")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ParkingSpot {
    @Id
    @Column(name = "spot_id", length = 3)
    private String spotId; // A01, A02, ..., F10

    @Column(nullable = false)
    private String row; // A, B, C, D, E, F

    @Column(nullable = false)
    private Integer number; // 1-10

    @Column(nullable = false)
    private Boolean hasElectricCharger; // true pour rows A et F

    @Column(nullable = false)
    private Boolean isAvailable = true;
}