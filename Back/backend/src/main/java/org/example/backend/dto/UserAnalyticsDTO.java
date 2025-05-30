package org.example.backend.dto;

import lombok.Data;
import java.util.List;

@Data
public class UserAnalyticsDTO {
    private String userId;
    private String userName;
    private String role;
    private Long totalReservations;
    private Long totalCheckIns;
    private Long totalNoShows;
    private Double checkInRate;
    private List<String> preferredSpots;
}