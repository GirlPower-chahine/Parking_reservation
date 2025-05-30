package org.example.backend.repository;

import org.example.backend.entity.Reservation;
import org.example.backend.entity.ReservationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, UUID> {

    @Query("SELECT r FROM Reservation r WHERE r.user.userId = :userId AND r.status = 'ACTIVE'")
    List<Reservation> findActiveReservationsByUser(@Param("userId") UUID userId);

    @Query("SELECT r FROM Reservation r WHERE r.user.userId = :userId ORDER BY r.startDateTime DESC")
    List<Reservation> findAllReservationsByUser(@Param("userId") UUID userId);

    @Query("SELECT COUNT(r) FROM Reservation r WHERE r.user.userId = :userId " +
            "AND DATE(r.startDateTime) >= :startDate AND DATE(r.startDateTime) <= :endDate " +
            "AND r.status = 'ACTIVE'")
    long countActiveReservationsInPeriod(@Param("userId") UUID userId,
                                         @Param("startDate") LocalDate startDate,
                                         @Param("endDate") LocalDate endDate);

    @Query("SELECT r FROM Reservation r WHERE DATE(r.startDateTime) = :date " +
            "AND r.status = 'ACTIVE' AND r.checkInTime IS NULL " +
            "AND HOUR(r.startDateTime) < 12")
    List<Reservation> findReservationsNeedingCheckIn(@Param("date") LocalDate date);

    @Query("SELECT r FROM Reservation r WHERE DATE(r.startDateTime) = :date " +
            "AND ((:timeSlot = 'MORNING' AND HOUR(r.startDateTime) < 12) " +
            "OR (:timeSlot = 'AFTERNOON' AND HOUR(r.startDateTime) >= 12)) " +
            "AND r.status IN ('ACTIVE', 'CHECKED_IN')")
    List<Reservation> findActiveReservationsByDateAndTimeSlot(@Param("date") LocalDate date,
                                                              @Param("timeSlot") String timeSlot);

    @Query("SELECT r FROM Reservation r WHERE r.parkingSpot.spotId = :spotId " +
            "AND DATE(r.startDateTime) = :date " +
            "AND ((:timeSlot = 'MORNING' AND HOUR(r.startDateTime) < 12) " +
            "OR (:timeSlot = 'AFTERNOON' AND HOUR(r.startDateTime) >= 12)) " +
            "AND r.status = 'ACTIVE'")
    Reservation findActiveReservationBySpotAndDateTime(@Param("spotId") String spotId,
                                                       @Param("date") LocalDate date,
                                                       @Param("timeSlot") String timeSlot);

    // Queries pour les réservations groupées
    @Query("SELECT r FROM Reservation r WHERE r.groupId = :groupId AND r.user.userId = :userId")
    List<Reservation> findByGroupIdAndUserId(@Param("groupId") String groupId, @Param("userId") UUID userId);

    // Queries pour Analytics
    @Query("SELECT COUNT(r) FROM Reservation r WHERE DATE(r.startDateTime) >= :startDate " +
            "AND DATE(r.startDateTime) <= :endDate")
    Long countReservationsInPeriod(@Param("startDate") LocalDate startDate,
                                   @Param("endDate") LocalDate endDate);

    @Query("SELECT COUNT(r) FROM Reservation r WHERE DATE(r.startDateTime) >= :startDate " +
            "AND DATE(r.startDateTime) <= :endDate AND r.checkInTime IS NOT NULL")
    Long countCheckedInReservationsInPeriod(@Param("startDate") LocalDate startDate,
                                            @Param("endDate") LocalDate endDate);

    @Query("SELECT COUNT(r) FROM Reservation r WHERE DATE(r.startDateTime) >= :startDate " +
            "AND DATE(r.startDateTime) <= :endDate AND r.parkingSpot.hasElectricCharger = true")
    Long countElectricReservationsInPeriod(@Param("startDate") LocalDate startDate,
                                           @Param("endDate") LocalDate endDate);

    @Query("SELECT COUNT(r) FROM Reservation r WHERE DATE(r.startDateTime) = :date")
    Long countReservationsByDate(@Param("date") LocalDate date);

    @Query("SELECT r FROM Reservation r WHERE r.startDateTime BETWEEN :start AND :end")
    List<Reservation> findAllByDateRange(@Param("start") LocalDateTime start,
                                         @Param("end") LocalDateTime end);

    // Queries pour le controller
    @Query("SELECT r FROM Reservation r WHERE r.user.userId = :userId " +
            "AND DATE(r.startDateTime) >= :startDate AND DATE(r.startDateTime) <= :endDate " +
            "ORDER BY r.startDateTime DESC")
    List<Reservation> findReservationsByUserAndDateRange(@Param("userId") UUID userId,
                                                         @Param("startDate") LocalDate startDate,
                                                         @Param("endDate") LocalDate endDate);

    @Query("SELECT r FROM Reservation r WHERE DATE(r.startDateTime) >= :startDate " +
            "AND DATE(r.startDateTime) <= :endDate " +
            "AND (:status IS NULL OR r.status = :status) " +
            "ORDER BY r.startDateTime DESC")
    List<Reservation> findReservationsHistory(@Param("startDate") LocalDate startDate,
                                              @Param("endDate") LocalDate endDate,
                                              @Param("status") String status);

    // NOUVELLES MÉTHODES pour Analytics et Scheduler
    @Query("SELECT COUNT(r) FROM Reservation r WHERE DATE(r.startDateTime) >= :startDate " +
            "AND DATE(r.startDateTime) <= :endDate AND r.status = 'COMPLETED'")
    Long countCompletedReservationsInPeriod(@Param("startDate") LocalDate startDate,
                                            @Param("endDate") LocalDate endDate);

    @Query("SELECT r FROM Reservation r WHERE r.status = 'CHECKED_IN' " +
            "AND r.endDateTime <= :endTime")
    List<Reservation> findCheckedInReservationsEndingBefore(@Param("endTime") LocalDateTime endTime);

    @Query("SELECT r FROM Reservation r WHERE r.status = :status " +
            "AND DATE(r.endDateTime) = DATE(:endDateTime) " +
            "AND HOUR(r.endDateTime) = HOUR(:endDateTime)")
    List<Reservation> findByStatusAndEndDateTime(@Param("status") ReservationStatus status,
                                                 @Param("endDateTime") LocalDateTime endDateTime);
}