package org.example.backend.service;

import org.example.backend.dto.ParkingSpotAvailabilityDTO;
import org.example.backend.entity.ParkingSpot;
import org.example.backend.entity.Reservation;
import org.example.backend.repository.ParkingSpotRepository;
import org.example.backend.repository.ReservationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParkingSpotService {

    private final ParkingSpotRepository parkingSpotRepository;
    private final ReservationRepository reservationRepository;

    public List<ParkingSpotAvailabilityDTO> getParkingAvailability(LocalDate date, String timeSlot) {
        List<ParkingSpot> allSpots = parkingSpotRepository.findAll();

        List<Reservation> reservations = reservationRepository.findActiveReservationsByDateAndTimeSlot(date, timeSlot);

        Map<String, Reservation> reservationMap = reservations.stream()
                .collect(Collectors.toMap(
                        r -> r.getParkingSpot().getSpotId(),
                        r -> r
                ));
        return allSpots.stream()
                .map(spot -> {
                    ParkingSpotAvailabilityDTO dto = new ParkingSpotAvailabilityDTO();
                    dto.setSpotId(spot.getSpotId());
                    dto.setRowIdentifier(spot.getRowIdentifier());
                    dto.setSpotNumber(spot.getSpotNumber());
                    dto.setHasElectricCharger(spot.getHasElectricCharger());

                    Reservation reservation = reservationMap.get(spot.getSpotId());
                    if (reservation != null) {
                        dto.setIsAvailable(false);
                        dto.setReservedBy(reservation.getUser().getFirstName());
                    } else {
                        dto.setIsAvailable(true);
                        dto.setReservedBy(null);
                    }

                    return dto;
                })
                .collect(Collectors.toList());
    }

    public List<ParkingSpot> getAllSpots() {
        return parkingSpotRepository.findAll();
    }
}