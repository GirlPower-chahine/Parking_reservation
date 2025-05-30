// ReservationDTO.java - VERSION COMPLÈTE
package org.example.backend.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class ReservationDTO {
    private LocalDate startDate;    // Date de début (pour réservations multi-jours)
    private LocalDate endDate;      // Date de fin (pour réservations multi-jours)
    private String timeSlot;        // "MORNING", "AFTERNOON", "FULL_DAY"
    private String spotId;          // Place spécifique (optionnel)
    private Boolean needsElectricCharger = false;

    // Pour compatibilité avec l'ancien système :
    public LocalDate getReservationDate() {
        return startDate;
    }

    public void setReservationDate(LocalDate date) {
        this.startDate = date;
        if (this.endDate == null) {
            this.endDate = date;
        }
    }
}