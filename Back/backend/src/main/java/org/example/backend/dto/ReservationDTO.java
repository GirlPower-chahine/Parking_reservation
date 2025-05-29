package org.example.backend.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class ReservationDTO {
    private LocalDate reservationDate;
    private String timeSlot;
    private String spotId;
    private Boolean needsElectricCharger = false;
}
