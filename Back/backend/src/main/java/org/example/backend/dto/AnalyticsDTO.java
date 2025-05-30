package org.example.backend.dto;

import lombok.Data;

import java.util.Map;

@Data
public class AnalyticsDTO {
    private Double averageOccupancyRate;
    private Double noShowRate;
    private Double electricChargerUsageRate;
    private Map<String, Double> dailyStats;
    private Long totalReservationsThisMonth;
    private Long activeReservationsToday;
}