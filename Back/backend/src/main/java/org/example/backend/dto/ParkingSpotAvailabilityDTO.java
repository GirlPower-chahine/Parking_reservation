package org.example.backend.dto;

import lombok.Data;

@Data
public class ParkingSpotAvailabilityDTO {
    private String spotId;
    private String rowIdentifier;  // ← Changé de 'row' vers 'rowIdentifier'
    private Integer spotNumber;    // ← Changé de 'number' vers 'spotNumber'
    private Boolean hasElectricCharger;
    private Boolean isAvailable;
    private String reservedBy;
}