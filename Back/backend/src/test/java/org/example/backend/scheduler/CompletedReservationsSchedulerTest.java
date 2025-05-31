// CompletedReservationsSchedulerTest.java
package org.example.backend.scheduler;

import org.example.backend.entity.Reservation;
import org.example.backend.entity.ReservationStatus;
import org.example.backend.entity.User;
import org.example.backend.entity.ParkingSpot;
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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class CompletedReservationsSchedulerTest {

    @Mock
    private ReservationRepository reservationRepository;

    @InjectMocks
    private CompletedReservationsScheduler completedReservationsScheduler;

    private Reservation checkedInReservation1;
    private Reservation checkedInReservation2;
    private User testUser;
    private ParkingSpot testSpot;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUserId(UUID.randomUUID());
        testUser.setUsername("test@example.com");
        testUser.setFirstName("Test");

        testSpot = new ParkingSpot();
        testSpot.setSpotId("A01");
        testSpot.setRowIdentifier("A");
        testSpot.setSpotNumber(1);

        // Réservation checked-in qui doit être complétée
        checkedInReservation1 = new Reservation();
        checkedInReservation1.setReservationId(UUID.randomUUID());
        checkedInReservation1.setUser(testUser);
        checkedInReservation1.setParkingSpot(testSpot);
        checkedInReservation1.setStartDateTime(LocalDate.now().atTime(LocalTime.of(8, 0)));
        checkedInReservation1.setEndDateTime(LocalDate.now().atTime(LocalTime.of(12, 0)));
        checkedInReservation1.setStatus(ReservationStatus.CHECKED_IN);
        checkedInReservation1.setCheckInTime(LocalDateTime.now().minusHours(4));

        // Autre réservation checked-in
        checkedInReservation2 = new Reservation();
        checkedInReservation2.setReservationId(UUID.randomUUID());
        checkedInReservation2.setUser(testUser);
        checkedInReservation2.setParkingSpot(testSpot);
        checkedInReservation2.setStartDateTime(LocalDate.now().atTime(LocalTime.of(14, 0)));
        checkedInReservation2.setEndDateTime(LocalDate.now().atTime(LocalTime.of(18, 0)));
        checkedInReservation2.setStatus(ReservationStatus.CHECKED_IN);
        checkedInReservation2.setCheckInTime(LocalDateTime.now().minusHours(2));
    }

    @Test
    void markReservationsAsCompleted_shouldUpdateCheckedInReservations() {
        // GIVEN
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.of(18, 0));
        when(reservationRepository.findCheckedInReservationsEndingBefore(endOfDay))
                .thenReturn(Arrays.asList(checkedInReservation1, checkedInReservation2));
        when(reservationRepository.saveAll(any(List.class)))
                .thenReturn(Arrays.asList(checkedInReservation1, checkedInReservation2));

        // WHEN
        completedReservationsScheduler.markReservationsAsCompleted();

        // THEN
        assertEquals(ReservationStatus.COMPLETED, checkedInReservation1.getStatus());
        assertEquals(ReservationStatus.COMPLETED, checkedInReservation2.getStatus());

        verify(reservationRepository, times(1)).findCheckedInReservationsEndingBefore(any(LocalDateTime.class));
        verify(reservationRepository, times(1)).saveAll(Arrays.asList(checkedInReservation1, checkedInReservation2));
    }

    @Test
    void markReservationsAsCompleted_shouldHandleEmptyList() {
        // GIVEN
        when(reservationRepository.findCheckedInReservationsEndingBefore(any(LocalDateTime.class)))
                .thenReturn(Collections.emptyList());

        // WHEN
        completedReservationsScheduler.markReservationsAsCompleted();

        // THEN
        verify(reservationRepository, times(1)).findCheckedInReservationsEndingBefore(any(LocalDateTime.class));
        verify(reservationRepository, times(1)).saveAll(Collections.emptyList());
    }

    @Test
    void completeMorningReservations_shouldCompleteMorningReservationsOnly() {
        // GIVEN
        LocalDate today = LocalDate.now();
        LocalDateTime morningEnd = today.atTime(LocalTime.of(12, 0));

        // Seule la réservation du matin doit être trouvée
        when(reservationRepository.findByStatusAndEndDateTime(ReservationStatus.CHECKED_IN, morningEnd))
                .thenReturn(Arrays.asList(checkedInReservation1));
        when(reservationRepository.saveAll(any(List.class)))
                .thenReturn(Arrays.asList(checkedInReservation1));

        // WHEN
        completedReservationsScheduler.completeMorningReservations();

        // THEN
        assertEquals(ReservationStatus.COMPLETED, checkedInReservation1.getStatus());

        verify(reservationRepository, times(1)).findByStatusAndEndDateTime(ReservationStatus.CHECKED_IN, morningEnd);
        verify(reservationRepository, times(1)).saveAll(Arrays.asList(checkedInReservation1));
    }

    @Test
    void completeMorningReservations_shouldNotCallSave_whenNoMorningReservations() {
        // GIVEN
        LocalDateTime morningEnd = LocalDate.now().atTime(LocalTime.of(12, 0));
        when(reservationRepository.findByStatusAndEndDateTime(ReservationStatus.CHECKED_IN, morningEnd))
                .thenReturn(Collections.emptyList());

        // WHEN
        completedReservationsScheduler.completeMorningReservations();

        // THEN
        verify(reservationRepository, times(1)).findByStatusAndEndDateTime(ReservationStatus.CHECKED_IN, morningEnd);
        verify(reservationRepository, never()).saveAll(any(List.class));
    }

    @Test
    void markReservationsAsCompleted_shouldOnlyUpdateCheckedInStatus() {
        // GIVEN
        Reservation activeReservation = new Reservation();
        activeReservation.setStatus(ReservationStatus.ACTIVE);

        Reservation expiredReservation = new Reservation();
        expiredReservation.setStatus(ReservationStatus.EXPIRED);

        List<Reservation> mixedReservations = Arrays.asList(
                checkedInReservation1,
                activeReservation,
                expiredReservation
        );

        when(reservationRepository.findCheckedInReservationsEndingBefore(any(LocalDateTime.class)))
                .thenReturn(Arrays.asList(checkedInReservation1)); // Seules les CHECKED_IN sont retournées

        // WHEN
        completedReservationsScheduler.markReservationsAsCompleted();

        // THEN
        assertEquals(ReservationStatus.COMPLETED, checkedInReservation1.getStatus());
        assertEquals(ReservationStatus.ACTIVE, activeReservation.getStatus()); // Inchangé
        assertEquals(ReservationStatus.EXPIRED, expiredReservation.getStatus()); // Inchangé
    }

    @Test
    void scheduler_shouldHandleRepositoryException() {
        // GIVEN
        when(reservationRepository.findCheckedInReservationsEndingBefore(any(LocalDateTime.class)))
                .thenThrow(new RuntimeException("Database error"));

        // WHEN & THEN
        assertThrows(RuntimeException.class, () -> {
            completedReservationsScheduler.markReservationsAsCompleted();
        });

        verify(reservationRepository, times(1)).findCheckedInReservationsEndingBefore(any(LocalDateTime.class));
        verify(reservationRepository, never()).saveAll(any(List.class));
    }

    @Test
    void scheduler_shouldMarkReservationsBasedOnCurrentTime() {
        // GIVEN
        LocalDate today = LocalDate.now();
        LocalDateTime currentTime = LocalDateTime.now();

        // Mock pour simuler l'heure actuelle (18h30 par exemple)
        LocalDateTime endOfDay = today.atTime(LocalTime.of(18, 0));

        when(reservationRepository.findCheckedInReservationsEndingBefore(any(LocalDateTime.class)))
                .thenReturn(Arrays.asList(checkedInReservation1));

        // WHEN
        completedReservationsScheduler.markReservationsAsCompleted();

        // THEN
        verify(reservationRepository).findCheckedInReservationsEndingBefore(argThat(dateTime ->
                dateTime.toLocalDate().equals(today) &&
                        dateTime.toLocalTime().equals(LocalTime.of(18, 0))
        ));
    }
}