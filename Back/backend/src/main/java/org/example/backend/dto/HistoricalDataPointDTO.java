package org.example.backend.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class HistoricalDataPointDTO {
    private LocalDate date;
    private Long totalReservations;
    private Double occupancyRate;
    private Double noShowRate;
}