package org.example.backend.dto;

import lombok.Data;
import java.util.Map;

@Data
public class ParkingSpotAnalyticsDTO {
    private String spotId;
    private Long totalReservations;
    private Long totalCheckIns;
    private Long totalNoShows;
    private Double utilizationRate;
    private Boolean hasElectricCharger;
    private Map<String, Long> usageByTimeSlot;
}

