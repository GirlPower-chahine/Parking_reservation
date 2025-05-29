package org.example.backend.repository;

import org.example.backend.entity.Reservation;
import org.example.backend.entity.ReservationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, UUID> {

    @Query("SELECT r FROM Reservation r WHERE r.user.userId = :userId AND r.status = 'ACTIVE'")
    List<Reservation> findActiveReservationsByUser(@Param("userId") UUID userId);

    @Query("SELECT r FROM Reservation r WHERE r.user.userId = :userId")
    List<Reservation> findAllReservationsByUser(@Param("userId") UUID userId);

    @Query("SELECT COUNT(r) FROM Reservation r WHERE r.user.userId = :userId " +
            "AND r.reservationDate >= :startDate AND r.reservationDate <= :endDate " +
            "AND r.status = 'ACTIVE'")
    long countActiveReservationsInPeriod(@Param("userId") UUID userId,
                                         @Param("startDate") LocalDate startDate,
                                         @Param("endDate") LocalDate endDate);

    @Query("SELECT r FROM Reservation r WHERE r.reservationDate = :date AND r.status = 'ACTIVE' " +
            "AND r.checkInTime IS NULL")
    List<Reservation> findReservationsNeedingCheckIn(@Param("date") LocalDate date);

    @Query("SELECT r FROM Reservation r WHERE r.reservationDate = :date AND r.timeSlot = :timeSlot AND r.status = 'ACTIVE'")
    List<Reservation> findActiveReservationsByDateAndTimeSlot(@Param("date") LocalDate date, @Param("timeSlot") String timeSlot);

    @Query("SELECT r FROM Reservation r WHERE r.parkingSpot.spotId = :spotId " +
            "AND r.reservationDate = :date AND r.timeSlot = :timeSlot AND r.status = 'ACTIVE'")
    Reservation findActiveReservationBySpotAndDateTime(@Param("spotId") String spotId,
                                                       @Param("date") LocalDate date,
                                                       @Param("timeSlot") String timeSlot);
}
