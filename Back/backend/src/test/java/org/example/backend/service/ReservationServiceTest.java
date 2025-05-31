package org.example.backend.service;

import org.example.backend.dto.CheckInDTO;
import org.example.backend.dto.ReservationDTO;
import org.example.backend.dto.ReservationResponseDTO;
import org.example.backend.entity.ParkingSpot;
import org.example.backend.entity.Reservation;
import org.example.backend.entity.ReservationStatus;
import org.example.backend.entity.User;
import org.example.backend.exception.BusinessException;
import org.example.backend.exception.ConcurrencyException;
import org.example.backend.repository.ParkingSpotRepository;
import org.example.backend.repository.ReservationRepository;
import org.example.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.orm.ObjectOptimisticLockingFailureException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ReservationServiceTest {

    @Mock
    private ReservationRepository reservationRepository;
    @Mock
    private ParkingSpotRepository parkingSpotRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private EmailQueueService emailQueueService;

    @InjectMocks
    private ReservationService reservationService;

    private UUID userId;
    private User employeeUser;
    private User managerUser;
    private ReservationDTO reservationDTO;
    private ParkingSpot spotB05;
    private ParkingSpot spotA01;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();

        employeeUser = new User();
        employeeUser.setUserId(userId);
        employeeUser.setUsername("employee@test.com");
        employeeUser.setFirstName("John");
        employeeUser.setRole("EMPLOYEE");

        managerUser = new User();
        managerUser.setUserId(UUID.randomUUID());
        managerUser.setUsername("manager@test.com");
        managerUser.setFirstName("Sarah");
        managerUser.setRole("MANAGER");

        spotB05 = new ParkingSpot();
        spotB05.setSpotId("B05");
        spotB05.setRowIdentifier("B");
        spotB05.setSpotNumber(5);
        spotB05.setHasElectricCharger(false);
        spotB05.setVersion(0L);

        spotA01 = new ParkingSpot();
        spotA01.setSpotId("A01");
        spotA01.setRowIdentifier("A");
        spotA01.setSpotNumber(1);
        spotA01.setHasElectricCharger(true);
        spotA01.setVersion(0L);

        // ✅ CORRIGÉ : Dates dans le FUTUR pour éviter "date dans le passé"
        reservationDTO = new ReservationDTO();
        reservationDTO.setStartDate(LocalDate.now().plusDays(1)); // Demain
        reservationDTO.setEndDate(LocalDate.now().plusDays(1));   // Demain
        reservationDTO.setTimeSlot("AFTERNOON");
        reservationDTO.setSpotId("B05");
        reservationDTO.setNeedsElectricCharger(false);
    }

    @Test
    void createReservation_shouldThrowException_whenEmployeeExceeds5DayLimit() {
        // GIVEN
        // ✅ CORRIGÉ : Dates valides dans le futur, mais trop de jours
        reservationDTO.setStartDate(LocalDate.now().plusDays(1));
        reservationDTO.setEndDate(LocalDate.now().plusDays(10)); // Plus de 5 jours ouvrables
        when(userRepository.findById(userId)).thenReturn(Optional.of(employeeUser));

        // WHEN & THEN
        BusinessException exception = assertThrows(BusinessException.class, () -> {
            reservationService.createReservation(userId, reservationDTO);
        });

        assertEquals("Les employés ne peuvent réserver que 5 jours maximum", exception.getMessage());
        verify(reservationRepository, never()).save(any(Reservation.class));
    }


    @Test
    void cancelReservation_shouldCancelSuccessfully() {
        // GIVEN
        UUID reservationId = UUID.randomUUID();
        Reservation existingReservation = new Reservation();
        existingReservation.setReservationId(reservationId);
        existingReservation.setUser(employeeUser);
        existingReservation.setParkingSpot(spotB05);
        existingReservation.setStartDateTime(LocalDate.now().atTime(LocalTime.of(14, 0)));
        existingReservation.setStatus(ReservationStatus.ACTIVE);

        when(reservationRepository.findById(reservationId)).thenReturn(Optional.of(existingReservation));
        when(reservationRepository.save(any(Reservation.class))).thenReturn(existingReservation);
        doNothing().when(emailQueueService).queueReservationCancellation(anyString(), anyString(), anyString());

        // WHEN
        reservationService.cancelReservation(userId, reservationId);

        // THEN
        assertEquals(ReservationStatus.CANCELLED_BY_USER, existingReservation.getStatus());
        assertNotNull(existingReservation.getCanceledAt());
        verify(reservationRepository, times(1)).save(existingReservation);
        verify(emailQueueService, times(1)).queueReservationCancellation(anyString(), anyString(), anyString());
    }

    @Test
    void checkIn_shouldUpdateReservationStatus() {
        // GIVEN
        CheckInDTO checkInDTO = new CheckInDTO();
        checkInDTO.setSpotId("B05");

        Reservation activeReservation = new Reservation();
        activeReservation.setReservationId(UUID.randomUUID());
        activeReservation.setUser(employeeUser);
        activeReservation.setParkingSpot(spotB05);
        activeReservation.setStartDateTime(LocalDate.now().atTime(LocalTime.of(14, 0)));
        activeReservation.setEndDateTime(LocalDate.now().atTime(LocalTime.of(18, 0)));
        activeReservation.setStatus(ReservationStatus.ACTIVE);

        when(reservationRepository.findActiveReservationBySpotAndDateTime(anyString(), any(LocalDate.class), anyString()))
                .thenReturn(activeReservation);
        when(reservationRepository.save(any(Reservation.class))).thenReturn(activeReservation);

        // WHEN
        ReservationResponseDTO response = reservationService.checkIn(userId, checkInDTO);

        // THEN
        assertNotNull(response);
        assertEquals("CHECKED_IN", response.getStatus());
        assertNotNull(response.getCheckInTime());
        assertEquals(ReservationStatus.CHECKED_IN, activeReservation.getStatus());
        assertNotNull(activeReservation.getCheckInTime());
        verify(reservationRepository, times(1)).save(activeReservation);
    }

    @Test
    void checkIn_shouldThrowException_whenNoActiveReservation() {
        // GIVEN
        CheckInDTO checkInDTO = new CheckInDTO();
        checkInDTO.setSpotId("B05");

        when(reservationRepository.findActiveReservationBySpotAndDateTime(anyString(), any(LocalDate.class), anyString()))
                .thenReturn(null); // Aucune réservation active

        // WHEN & THEN
        BusinessException exception = assertThrows(BusinessException.class, () -> {
            reservationService.checkIn(userId, checkInDTO);
        });

        assertEquals("Aucune réservation active trouvée pour cette place", exception.getMessage());
        verify(reservationRepository, never()).save(any(Reservation.class));
    }
}