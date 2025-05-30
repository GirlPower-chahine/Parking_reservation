package org.example.backend.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class ReservationResponseDTO {
    private UUID reservationId;
    private String spotId;
    private LocalDate reservationDate;
    private String timeSlot;
    private String status;
    private LocalDateTime checkInTime;
    private LocalDateTime createdAt;
    private String userName;
    private String groupId;
}