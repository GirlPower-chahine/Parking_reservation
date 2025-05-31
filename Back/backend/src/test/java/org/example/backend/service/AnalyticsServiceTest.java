package org.example.backend.service;

import org.example.backend.dto.DashboardSummaryDTO;
import org.example.backend.entity.ParkingSpot;
import org.example.backend.entity.Reservation;
import org.example.backend.entity.ReservationStatus;
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
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AnalyticsServiceTest {

    @Mock
    private ReservationRepository reservationRepository;
    @Mock
    private ParkingSpotRepository parkingSpotRepository;

    @InjectMocks
    private AnalyticsService analyticsService;

    private ParkingSpot spotA01;
    private ParkingSpot spotB05;
    private Reservation reservation1;
    private Reservation reservation2;

    @BeforeEach
    void setUp() {
        spotA01 = new ParkingSpot();
        spotA01.setSpotId("A01");
        spotA01.setHasElectricCharger(true);

        spotB05 = new ParkingSpot();
        spotB05.setSpotId("B05");
        spotB05.setHasElectricCharger(false);

        // Réservation active et check-in pour aujourd'hui
        reservation1 = new Reservation();
        reservation1.setReservationId(UUID.randomUUID());
        reservation1.setParkingSpot(spotA01);
        reservation1.setReservationDate(LocalDate.now());
        reservation1.setTimeSlot("FULL_DAY");
        reservation1.setStatus(ReservationStatus.CHECKED_IN);
        reservation1.setCheckInTime(LocalDateTime.now());

        // Réservation annulée automatiquement pour aujourd'hui (non-présentation)
        reservation2 = new Reservation();
        reservation2.setReservationId(UUID.randomUUID());
        reservation2.setParkingSpot(spotB05);
        reservation2.setReservationDate(LocalDate.now());
        reservation2.setTimeSlot("FULL_DAY");
        reservation2.setStatus(ReservationStatus.CANCELED_AUTO);
        reservation2.setCheckInTime(null);
    }

    @Test
    void getDashboardSummary_shouldCalculateCorrectMetrics() {
        // GIVEN
        when(reservationRepository.findByReservationDate(LocalDate.now()))
                .thenReturn(Arrays.asList(reservation1, reservation2));
        when(parkingSpotRepository.findAll()).thenReturn(Arrays.asList(spotA01, spotB05));

        // WHEN
        DashboardSummaryDTO summary = analyticsService.getDashboardSummary();

        // THEN
        assertNotNull(summary);
        assertEquals(1, summary.getActiveReservationsCount()); // reservation1
        assertEquals(1, summary.getNoShowCount()); // reservation2
        assertEquals(2, summary.getTotalReservationsToday()); // reservation1 + reservation2
        assertEquals(2, summary.getTotalParkingSpots()); // spotA01 + spotB05
        // Ajoutez des assertions pour les autres métriques comme le taux d'occupation, etc.
        // Assurez-vous que votre DTO et votre service calculent ces métriques.
    }

    @Test
    void getDashboardSummary_shouldHandleNoReservations() {
        // GIVEN
        when(reservationRepository.findByReservationDate(LocalDate.now()))
                .thenReturn(Collections.emptyList());
        when(parkingSpotRepository.findAll()).thenReturn(Arrays.asList(spotA01, spotB05));

        // WHEN
        DashboardSummaryDTO summary = analyticsService.getDashboardSummary();

        // THEN
        assertNotNull(summary);
        assertEquals(0, summary.getActiveReservationsCount());
        assertEquals(0, summary.getNoShowCount());
        assertEquals(0, summary.getTotalReservationsToday());
        assertEquals(2, summary.getTotalParkingSpots());
    }

    // TODO: Ajouter des tests pour les méthodes de tendances mensuelles, historiques, etc.
    // TODO: Tester le calcul du taux d'utilisation des places électriques.
}