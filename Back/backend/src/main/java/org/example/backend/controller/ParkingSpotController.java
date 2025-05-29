package org.example.backend.controller;

import org.example.backend.dto.ParkingSpotAvailabilityDTO;
import org.example.backend.entity.ParkingSpot;
import org.example.backend.service.ParkingSpotService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/parking")
@RequiredArgsConstructor
public class ParkingSpotController {

    private final ParkingSpotService parkingSpotService;

    @GetMapping("/availability")
    public ResponseEntity<List<ParkingSpotAvailabilityDTO>> getParkingAvailability(
            @RequestParam String date,
            @RequestParam String timeSlot) {

        LocalDate reservationDate = LocalDate.parse(date);
        List<ParkingSpotAvailabilityDTO> availability = parkingSpotService.getParkingAvailability(reservationDate, timeSlot);
        return ResponseEntity.ok(availability);
    }

    @GetMapping("/spots")
    public ResponseEntity<List<ParkingSpot>> getAllParkingSpots() {
        return ResponseEntity.ok(parkingSpotService.getAllSpots());
    }
}