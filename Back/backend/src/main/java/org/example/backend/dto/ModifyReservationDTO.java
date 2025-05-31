package org.example.backend.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class ModifyReservationDTO {
    private String newSpotId;
    private LocalDate newDate;
    private String reason;
}