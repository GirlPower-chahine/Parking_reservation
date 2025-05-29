package org.example.backend.dto;

import lombok.Data;

@Data
public class ParkingSpotAvailabilityDTO {
    private String spotId;
    private String row;
    private Integer number;
    private Boolean hasElectricCharger;
    private Boolean isAvailable;
    private String reservedBy;
}