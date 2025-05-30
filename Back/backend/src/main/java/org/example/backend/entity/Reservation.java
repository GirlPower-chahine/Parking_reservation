// src/main/java/org/example/backend.entity/Reservation.java
package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "RESERVATIONS")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Reservation {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID reservationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "spot_id", nullable = false)
    private ParkingSpot parkingSpot;

    @Column(nullable = false)
    private LocalDateTime startDateTime; // Début de la période de réservation (permet plus de flexibilité que LocalDate + String)

    @Column(nullable = false)
    private LocalDateTime endDateTime; // Fin de la période de réservation (permet les durées de 5 jours, 1 mois, etc.)

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReservationStatus status = ReservationStatus.ACTIVE;

    @Column // peut être null si pas encore check-in
    private LocalDateTime checkInTime;

    @Column(name = "created_at", nullable = false, updatable = false) // Horodatage de création
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false) // Horodatage de dernière modification
    private LocalDateTime updatedAt;

    @PrePersist // Méthode appelée avant la première persistance de l'entité
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate // Méthode appelée avant chaque mise à jour de l'entité
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}