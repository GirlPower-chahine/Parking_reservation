package org.example.backend.scheduler;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.backend.entity.Reservation;
import org.example.backend.entity.ReservationStatus;
import org.example.backend.repository.ReservationRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class CompletedReservationsScheduler {

    private final ReservationRepository reservationRepository;

    /**
     * Cette tâche s'exécute à 18h30 chaque jour ouvrable
     * pour marquer comme COMPLETED toutes les réservations CHECKED_IN du jour
     */
    @Scheduled(cron = "0 30 18 * * MON-FRI")
    @Transactional
    public void markReservationsAsCompleted() {
        LocalDate today = LocalDate.now();
        LocalDateTime endOfDay = today.atTime(LocalTime.of(18, 0));

        // Trouver toutes les réservations CHECKED_IN qui sont terminées
        List<Reservation> reservationsToComplete = reservationRepository
                .findCheckedInReservationsEndingBefore(endOfDay);

        log.info("Marking {} reservations as COMPLETED", reservationsToComplete.size());

        for (Reservation reservation : reservationsToComplete) {
            reservation.setStatus(ReservationStatus.COMPLETED);
        }

        reservationRepository.saveAll(reservationsToComplete);

        log.info("Successfully marked {} reservations as COMPLETED", reservationsToComplete.size());
    }

    /**
     * Alternative: Marquer comme COMPLETED immédiatement après la fin du créneau
     * Cette tâche s'exécute à 12h15 pour les réservations du matin
     */
    @Scheduled(cron = "0 15 12 * * MON-FRI")
    @Transactional
    public void completeMorningReservations() {
        LocalDate today = LocalDate.now();
        LocalDateTime morningEnd = today.atTime(LocalTime.of(12, 0));

        List<Reservation> morningReservations = reservationRepository
                .findByStatusAndEndDateTime(ReservationStatus.CHECKED_IN, morningEnd);

        for (Reservation reservation : morningReservations) {
            reservation.setStatus(ReservationStatus.COMPLETED);
        }

        if (!morningReservations.isEmpty()) {
            reservationRepository.saveAll(morningReservations);
            log.info("Marked {} morning reservations as COMPLETED", morningReservations.size());
        }
    }
}