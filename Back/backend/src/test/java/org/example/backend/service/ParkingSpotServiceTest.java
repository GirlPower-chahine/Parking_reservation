package org.example.backend.service;

import org.example.backend.dto.ParkingSpotAvailabilityDTO;
import org.example.backend.entity.ParkingSpot;
import org.example.backend.entity.Reservation;
import org.example.backend.entity.ReservationStatus;
import org.example.backend.entity.User;
import org.example.backend.repository.ParkingSpotRepository;
import org.example.backend.repository.ReservationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors; // ✅ IMPORT AJOUTÉ

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ParkingSpotServiceTest {

    @Mock
    private ParkingSpotRepository parkingSpotRepository;
    @Mock
    private ReservationRepository reservationRepository;

    @InjectMocks
    private ParkingSpotService parkingSpotService;

    private ParkingSpot spotA01;
    private ParkingSpot spotB05;
    private ParkingSpot spotF10;
    private User testUser;

    @BeforeEach
    void setUp() {
        // Test user
        testUser = new User();
        testUser.setUserId(UUID.randomUUID());
        testUser.setUsername("test@example.com");
        testUser.setFirstName("TestUser");

        // ✅ Parking spots setup selon votre vraie entité
        spotA01 = new ParkingSpot();
        spotA01.setSpotId("A01");
        spotA01.setRowIdentifier("A");
        spotA01.setSpotNumber(1);
        spotA01.setHasElectricCharger(true);
        spotA01.setIsAvailable(true);
        spotA01.setVersion(0L);

        spotB05 = new ParkingSpot();
        spotB05.setSpotId("B05");
        spotB05.setRowIdentifier("B");
        spotB05.setSpotNumber(5);
        spotB05.setHasElectricCharger(false);
        spotB05.setIsAvailable(true);
        spotB05.setVersion(0L);

        spotF10 = new ParkingSpot();
        spotF10.setSpotId("F10");
        spotF10.setRowIdentifier("F");
        spotF10.setSpotNumber(10);
        spotF10.setHasElectricCharger(true);
        spotF10.setIsAvailable(true);
        spotF10.setVersion(0L);
    }

    @Test
    void getAllSpots_shouldReturnAllParkingSpots() {
        // GIVEN
        when(parkingSpotRepository.findAll()).thenReturn(Arrays.asList(spotA01, spotB05, spotF10));

        // WHEN
        List<ParkingSpot> spots = parkingSpotService.getAllSpots();

        // THEN
        assertNotNull(spots);
        assertEquals(3, spots.size());
        assertTrue(spots.contains(spotA01));
        assertTrue(spots.contains(spotB05));
        assertTrue(spots.contains(spotF10));
        verify(parkingSpotRepository, times(1)).findAll();
    }

    @Test
    void getParkingAvailability_shouldReturnAvailableSpots_noReservations() {
        // GIVEN
        LocalDate date = LocalDate.of(2025, 6, 1);
        String timeSlot = "MORNING";

        when(parkingSpotRepository.findAll()).thenReturn(Arrays.asList(spotA01, spotB05));
        // ✅ Utilise la vraie méthode de votre repository
        when(reservationRepository.findActiveReservationsByDateAndTimeSlot(date, timeSlot))
                .thenReturn(Collections.emptyList());

        // WHEN
        List<ParkingSpotAvailabilityDTO> availability = parkingSpotService.getParkingAvailability(date, timeSlot);

        // THEN
        assertNotNull(availability);
        assertEquals(2, availability.size());

        // Vérifier que toutes les places sont disponibles
        assertTrue(availability.stream().allMatch(ParkingSpotAvailabilityDTO::getIsAvailable));
        assertTrue(availability.stream().anyMatch(dto -> dto.getSpotId().equals("A01")));
        assertTrue(availability.stream().anyMatch(dto -> dto.getSpotId().equals("B05")));

        verify(parkingSpotRepository, times(1)).findAll();
        verify(reservationRepository, times(1)).findActiveReservationsByDateAndTimeSlot(date, timeSlot);
    }

    @Test
    void getParkingAvailability_shouldMarkSpotAsUnavailable_whenReserved() {
        // GIVEN
        LocalDate date = LocalDate.of(2025, 6, 1);
        String timeSlot = "MORNING";

        // ✅ Créer une réservation selon votre vraie entité
        Reservation reservedSpotB05 = new Reservation();
        reservedSpotB05.setReservationId(UUID.randomUUID());
        reservedSpotB05.setUser(testUser);
        reservedSpotB05.setParkingSpot(spotB05);
        reservedSpotB05.setStartDateTime(date.atTime(LocalTime.of(8, 0)));
        reservedSpotB05.setEndDateTime(date.atTime(LocalTime.of(12, 0)));
        reservedSpotB05.setStatus(ReservationStatus.ACTIVE);

        when(parkingSpotRepository.findAll()).thenReturn(Arrays.asList(spotA01, spotB05));
        when(reservationRepository.findActiveReservationsByDateAndTimeSlot(date, timeSlot))
                .thenReturn(Arrays.asList(reservedSpotB05));

        // WHEN
        List<ParkingSpotAvailabilityDTO> availability = parkingSpotService.getParkingAvailability(date, timeSlot);

        // THEN
        assertNotNull(availability);
        assertEquals(2, availability.size());

        // Vérifier A01 disponible
        ParkingSpotAvailabilityDTO spotA01DTO = availability.stream()
                .filter(dto -> dto.getSpotId().equals("A01"))
                .findFirst().orElse(null);
        assertNotNull(spotA01DTO);
        assertTrue(spotA01DTO.getIsAvailable());
        assertNull(spotA01DTO.getReservedBy());

        // Vérifier B05 réservée
        ParkingSpotAvailabilityDTO spotB05DTO = availability.stream()
                .filter(dto -> dto.getSpotId().equals("B05"))
                .findFirst().orElse(null);
        assertNotNull(spotB05DTO);
        assertFalse(spotB05DTO.getIsAvailable());
        assertEquals("TestUser", spotB05DTO.getReservedBy());
    }

    @Test
    void getParkingAvailability_shouldFilterElectricChargerSpots() {
        // GIVEN
        LocalDate date = LocalDate.of(2025, 6, 1);
        String timeSlot = "MORNING";

        when(parkingSpotRepository.findAll()).thenReturn(Arrays.asList(spotA01, spotB05, spotF10));
        when(reservationRepository.findActiveReservationsByDateAndTimeSlot(date, timeSlot))
                .thenReturn(Collections.emptyList());

        // WHEN
        List<ParkingSpotAvailabilityDTO> allAvailability = parkingSpotService.getParkingAvailability(date, timeSlot);

        // Filtrer manuellement les places électriques (comme le ferait Flutter côté client)
        List<ParkingSpotAvailabilityDTO> electricAvailability = allAvailability.stream()
                .filter(ParkingSpotAvailabilityDTO::getHasElectricCharger)
                .collect(Collectors.toList()); // ✅ Maintenant Collectors est importé

        // THEN
        assertNotNull(electricAvailability);
        assertEquals(2, electricAvailability.size()); // A01 et F10
        assertTrue(electricAvailability.stream().anyMatch(dto -> dto.getSpotId().equals("A01")));
        assertTrue(electricAvailability.stream().anyMatch(dto -> dto.getSpotId().equals("F10")));
        assertFalse(electricAvailability.stream().anyMatch(dto -> dto.getSpotId().equals("B05")));

        // Vérifier que toutes ont des chargeurs électriques
        assertTrue(electricAvailability.stream().allMatch(ParkingSpotAvailabilityDTO::getHasElectricCharger));
    }

    @Test
    void getParkingAvailability_shouldHandleEmptySpotsList() {
        // GIVEN
        LocalDate date = LocalDate.of(2025, 6, 1);
        String timeSlot = "MORNING";

        when(parkingSpotRepository.findAll()).thenReturn(Collections.emptyList());
        when(reservationRepository.findActiveReservationsByDateAndTimeSlot(date, timeSlot))
                .thenReturn(Collections.emptyList());

        // WHEN
        List<ParkingSpotAvailabilityDTO> availability = parkingSpotService.getParkingAvailability(date, timeSlot);

        // THEN
        assertNotNull(availability);
        assertTrue(availability.isEmpty());
        verify(parkingSpotRepository, times(1)).findAll();
    }

    @Test
    void getParkingAvailability_shouldSetCorrectSpotProperties() {
        // GIVEN
        LocalDate date = LocalDate.of(2025, 6, 1);
        String timeSlot = "AFTERNOON";

        when(parkingSpotRepository.findAll()).thenReturn(Arrays.asList(spotA01));
        when(reservationRepository.findActiveReservationsByDateAndTimeSlot(date, timeSlot))
                .thenReturn(Collections.emptyList());

        // WHEN
        List<ParkingSpotAvailabilityDTO> availability = parkingSpotService.getParkingAvailability(date, timeSlot);

        // THEN
        assertNotNull(availability);
        assertEquals(1, availability.size());

        ParkingSpotAvailabilityDTO dto = availability.get(0);
        assertEquals("A01", dto.getSpotId());
        assertEquals("A", dto.getRowIdentifier());
        assertEquals(Integer.valueOf(1), dto.getSpotNumber());
        assertTrue(dto.getHasElectricCharger());
        assertTrue(dto.getIsAvailable());
        assertNull(dto.getReservedBy());
    }
}