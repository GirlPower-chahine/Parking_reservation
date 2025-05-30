package org.example.backend.service;

import org.example.backend.dto.CheckInDTO;
import org.example.backend.dto.ReservationDTO;
import org.example.backend.dto.ReservationResponseDTO;
import org.example.backend.entity.*;
import org.example.backend.repository.ParkingSpotRepository;
import org.example.backend.repository.ReservationRepository;
import org.example.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final ParkingSpotRepository parkingSpotRepository;
    private final UserRepository userRepository;

    private ParkingSpot findAvailableSpot(ReservationDTO dto) {
        List<ParkingSpot> availableSpots;

        if (dto.getNeedsElectricCharger()) {
            availableSpots = parkingSpotRepository.findAvailableElectricSpots(
                    dto.getReservationDate(), dto.getTimeSlot());
        } else {
            availableSpots = parkingSpotRepository.findAvailableSpots(
                    dto.getReservationDate(), dto.getTimeSlot());
        }

        if (dto.getSpotId() != null) {
            return availableSpots.stream()
                    .filter(spot -> spot.getSpotId().equals(dto.getSpotId()))
                    .findFirst()
                    .orElse(null);
        }

        return availableSpots.isEmpty() ? null : availableSpots.get(0);
    }

    @Transactional
    public ReservationResponseDTO createReservation(UUID userId, ReservationDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        validateReservationRules(user, dto);

        ParkingSpot availableSpot = findAvailableSpot(dto);
        if (availableSpot == null) {
            throw new RuntimeException("Aucune place disponible pour cette date et créneau");
        }

        Reservation reservation = new Reservation();
        reservation.setUser(user);
        reservation.setParkingSpot(availableSpot);

        LocalDateTime startTime = dto.getReservationDate().atTime(
                "MORNING".equals(dto.getTimeSlot()) ? 8 : 14, 0);
        LocalDateTime endTime = dto.getReservationDate().atTime(
                "MORNING".equals(dto.getTimeSlot()) ? 12 : 18, 0);

        reservation.setStartDateTime(startTime);
        reservation.setEndDateTime(endTime);
        reservation.setStatus(ReservationStatus.ACTIVE);

        Reservation saved = reservationRepository.save(reservation);

        return convertToResponseDTO(saved);
    }

    private void validateReservationRules(User user, ReservationDTO dto) {
        if (dto.getReservationDate().isBefore(LocalDate.now())) {
            throw new RuntimeException("Impossible de réserver dans le passé");
        }

        if ("EMPLOYEE".equals(user.getRole())) {
            validateEmployeeRules(user.getUserId(), dto);
        } else if ("MANAGER".equals(user.getRole())) {
            validateManagerRules(user.getUserId(), dto);
        }
    }

    private void validateEmployeeRules(UUID userId, ReservationDTO dto) {
        LocalDate startDate = LocalDate.now();
        LocalDate endDate = dto.getReservationDate();

        long activeReservations = reservationRepository.countActiveReservationsInPeriod(
                userId, startDate, endDate.plusDays(1));

        if (activeReservations >= 5) {
            throw new RuntimeException("Limite de 5 réservations atteinte");
        }
    }

    private void validateManagerRules(UUID userId, ReservationDTO dto) {
        LocalDate startDate = LocalDate.now();
        LocalDate endDate = dto.getReservationDate();

        if (endDate.isAfter(startDate.plusDays(30))) {
            throw new RuntimeException("Les managers ne peuvent réserver que 30 jours à l'avance maximum");
        }
    }

    @Transactional
    public ReservationResponseDTO createReservationWithSpecificSpot(UUID userId, ReservationDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        validateReservationRules(user, dto);

        if (dto.getSpotId() == null) {
            throw new RuntimeException("SpotId requis pour cette méthode");
        }

        ParkingSpot spot = parkingSpotRepository.findById(dto.getSpotId())
                .orElseThrow(() -> new RuntimeException("Place de parking non trouvée"));

        Reservation existingReservation = reservationRepository.findActiveReservationBySpotAndDateTime(
                dto.getSpotId(), dto.getReservationDate(), dto.getTimeSlot());

        if (existingReservation != null) {
            throw new RuntimeException("Cette place est déjà réservée pour ce créneau");
        }

        if (dto.getNeedsElectricCharger() && !spot.getHasElectricCharger()) {
            throw new RuntimeException("Cette place n'a pas de borne électrique");
        }

        Reservation reservation = new Reservation();
        reservation.setUser(user);
        reservation.setParkingSpot(spot);

        LocalDateTime startTime = dto.getReservationDate().atTime(
                "MORNING".equals(dto.getTimeSlot()) ? 8 : 14, 0);
        LocalDateTime endTime = dto.getReservationDate().atTime(
                "MORNING".equals(dto.getTimeSlot()) ? 12 : 18, 0);

        reservation.setStartDateTime(startTime);
        reservation.setEndDateTime(endTime);
        reservation.setStatus(ReservationStatus.ACTIVE);

        Reservation saved = reservationRepository.save(reservation);
        return convertToResponseDTO(saved);
    }

    @Transactional
    public void cancelReservation(UUID userId, UUID reservationId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new RuntimeException("Réservation non trouvée"));

        if (!reservation.getUser().getUserId().equals(userId)) {
            throw new RuntimeException("Vous ne pouvez annuler que vos propres réservations");
        }

        if (reservation.getStatus() != ReservationStatus.ACTIVE) {
            throw new RuntimeException("Cette réservation ne peut pas être annulée");
        }

        reservation.setStatus(ReservationStatus.CANCELLED);
        reservationRepository.save(reservation);
    }

    @Transactional
    public ReservationResponseDTO checkIn(UUID userId, CheckInDTO dto) {
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();

        String currentTimeSlot = now.isBefore(LocalTime.of(14, 0)) ? "MORNING" : "AFTERNOON";

        Reservation reservation = reservationRepository.findActiveReservationBySpotAndDateTime(
                dto.getSpotId(), today, currentTimeSlot);

        if (reservation == null) {
            throw new RuntimeException("Aucune réservation active trouvée pour cette place");
        }

        if (!reservation.getUser().getUserId().equals(userId)) {
            throw new RuntimeException("Cette réservation ne vous appartient pas");
        }

        if (reservation.getCheckInTime() != null) {
            throw new RuntimeException("Check-in déjà effectué");
        }

        reservation.setCheckInTime(LocalDateTime.now());
        reservation.setStatus(ReservationStatus.CHECKED_IN);

        Reservation saved = reservationRepository.save(reservation);
        return convertToResponseDTO(saved);
    }

    public List<ReservationResponseDTO> getUserReservations(UUID userId) {
        List<Reservation> reservations = reservationRepository.findAllReservationsByUser(userId);
        return reservations.stream()
                .map(this::convertToResponseDTO)
                .collect(Collectors.toList());
    }

    public List<ReservationResponseDTO> getUserActiveReservations(UUID userId) {
        List<Reservation> reservations = reservationRepository.findActiveReservationsByUser(userId);
        return reservations.stream()
                .map(this::convertToResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void expireReservationsAt11AM() {
        LocalDate today = LocalDate.now();
        List<Reservation> reservationsToExpire = reservationRepository.findReservationsNeedingCheckIn(today);

        for (Reservation reservation : reservationsToExpire) {
            reservation.setStatus(ReservationStatus.EXPIRED);
        }

        reservationRepository.saveAll(reservationsToExpire);
    }

    private ReservationResponseDTO convertToResponseDTO(Reservation reservation) {
        ReservationResponseDTO dto = new ReservationResponseDTO();
        dto.setReservationId(reservation.getReservationId());
        dto.setSpotId(reservation.getParkingSpot().getSpotId());

        dto.setReservationDate(reservation.getStartDateTime().toLocalDate());

        LocalTime startTime = reservation.getStartDateTime().toLocalTime();
        String timeSlot = startTime.isBefore(LocalTime.of(13, 0)) ? "MORNING" : "AFTERNOON";
        dto.setTimeSlot(timeSlot);

        dto.setStatus(reservation.getStatus().toString());
        dto.setCheckInTime(reservation.getCheckInTime());
        dto.setCreatedAt(reservation.getCreatedAt());
        dto.setUserName(reservation.getUser().getFirstName());
        return dto;
    }
}