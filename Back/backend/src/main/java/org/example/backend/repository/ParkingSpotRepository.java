package org.example.backend.repository;

import org.example.backend.entity.ParkingSpot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ParkingSpotRepository extends JpaRepository<ParkingSpot, String> {

    @Query("SELECT ps FROM ParkingSpot ps WHERE ps.hasElectricCharger = true")
    List<ParkingSpot> findElectricChargingSpots();

    @Query("SELECT ps FROM ParkingSpot ps WHERE ps.spotId NOT IN " +
            "(SELECT r.parkingSpot.spotId FROM Reservation r " +
            "WHERE DATE(r.startDateTime) = :date " +
            "AND ((:timeSlot = 'MORNING' AND HOUR(r.startDateTime) < 12) " +
            "OR (:timeSlot = 'AFTERNOON' AND HOUR(r.startDateTime) >= 12)) " +
            "AND r.status IN ('ACTIVE', 'CHECKED_IN'))")
    List<ParkingSpot> findAvailableSpots(@Param("date") LocalDate date, @Param("timeSlot") String timeSlot);

    @Query("SELECT ps FROM ParkingSpot ps WHERE ps.hasElectricCharger = true AND ps.spotId NOT IN " +
            "(SELECT r.parkingSpot.spotId FROM Reservation r " +
            "WHERE DATE(r.startDateTime) = :date " +
            "AND ((:timeSlot = 'MORNING' AND HOUR(r.startDateTime) < 12) " +
            "OR (:timeSlot = 'AFTERNOON' AND HOUR(r.startDateTime) >= 12)) " +
            "AND r.status IN ('ACTIVE', 'CHECKED_IN'))")
    List<ParkingSpot> findAvailableElectricSpots(@Param("date") LocalDate date, @Param("timeSlot") String timeSlot);

    // NOUVELLE MÉTHODE MANQUANTE pour Analytics :
    @Query("SELECT COUNT(ps) FROM ParkingSpot ps WHERE ps.hasElectricCharger = true")
    Long countElectricSpots();
}