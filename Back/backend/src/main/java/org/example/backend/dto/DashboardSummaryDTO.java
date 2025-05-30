package org.example.backend.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class DashboardSummaryDTO {
    private Double currentOccupancyRate;
    private Integer occupiedSpots;
    private Integer totalSpots;
    private Double todayNoShowRate;
    private List<Map<String, Object>> topUsedSpots;
    private Map<String, Object> weeklyTrend;
    private Double predictedOccupancyTomorrow;
    private Long completedToday;
    private Double completionRate;
}