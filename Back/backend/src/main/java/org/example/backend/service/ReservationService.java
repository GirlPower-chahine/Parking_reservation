package org.example.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.backend.dto.*;
import org.example.backend.entity.*;
import org.example.backend.exception.BusinessException;
import org.example.backend.exception.ConcurrencyException;
import org.example.backend.repository.*;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final ParkingSpotRepository parkingSpotRepository;
    private final UserRepository userRepository;
    private final EmailQueueService emailQueueService;

    @Transactional
    public List<ReservationResponseDTO> createReservation(UUID userId, ReservationDTO dto) {
        try {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new BusinessException("Utilisateur non trouvé"));

            // Validation des dates et du rôle
            validateReservationRequest(user, dto);

            // Génération des dates de réservation (jours ouvrables uniquement)
            List<LocalDate> workingDays = generateWorkingDays(dto.getStartDate(), dto.getEndDate());

            // Groupe unique pour lier les réservations multi-jours
            String groupId = UUID.randomUUID().toString();

            List<ReservationResponseDTO> createdReservations = new ArrayList<>();

            for (LocalDate date : workingDays) {
                // Trouver une place disponible pour chaque jour
                ParkingSpot spot = findAvailableSpot(date, dto);
                if (spot == null) {
                    throw new BusinessException(
                            String.format("Aucune place disponible le %s", date)
                    );
                }

                // Créer la réservation pour ce jour
                Reservation reservation = createDayReservation(user, spot, date, dto, groupId);
                Reservation saved = reservationRepository.save(reservation);
                createdReservations.add(convertToResponseDTO(saved));

                log.info("Réservation créée: {} pour {} le {}",
                        saved.getReservationId(), user.getUsername(), date);
            }

            // Envoyer email de confirmation
            emailQueueService.queueReservationConfirmation(
                    user.getUsername(),
                    createdReservations.get(0).getSpotId(),
                    dto.getStartDate().toString(),
                    dto.getTimeSlot()
            );

            return createdReservations;

        } catch (ObjectOptimisticLockingFailureException e) {
            log.warn("Conflit de concurrence lors de la réservation", e);
            throw new ConcurrencyException(
                    "La place sélectionnée n'est plus disponible. Veuillez réessayer."
            );
        }
    }



    private void validateReservationRequest(User user, ReservationDTO dto) {
        LocalDate today = LocalDate.now();

        if (dto.getStartDate().isBefore(today)) {
            throw new BusinessException("La date de début ne peut pas être dans le passé");
        }

        if (dto.getEndDate().isBefore(dto.getStartDate())) {
            throw new BusinessException("La date de fin doit être après la date de début");
        }

        List<LocalDate> requestedWorkingDays = generateWorkingDays(dto.getStartDate(), dto.getEndDate());
        long numberOfWorkingDaysInRequest = requestedWorkingDays.size();

        if ("EMPLOYEE".equals(user.getRole()) && numberOfWorkingDaysInRequest > 5) {
            throw new BusinessException("Les employés ne peuvent réserver que 5 jours ouvrables maximum par demande");
        }

        if ("MANAGER".equals(user.getRole()) && numberOfWorkingDaysInRequest > 30) {
            throw new BusinessException("Les managers ne peuvent réserver que 30 jours ouvrables maximum par demande");
        }

        if ("EMPLOYEE".equals(user.getRole())) {
            long activeWorkingDaysCount = countActiveWorkingDays(user.getUserId(), today, dto.getEndDate());

            if ((activeWorkingDaysCount + numberOfWorkingDaysInRequest) > 5) {
                throw new BusinessException(String.format(
                        "Limite de 5 jours ouvrables atteinte. Vous avez déjà %d jour(s) réservé(s) et tentez d'en ajouter %d.",
                        activeWorkingDaysCount, numberOfWorkingDaysInRequest
                ));
            }
        }

        if ("MANAGER".equals(user.getRole())) {
            long totalActiveReservations = countAllActiveWorkingDays(user.getUserId());

            if ((totalActiveReservations + numberOfWorkingDaysInRequest) > 30) {
                throw new BusinessException(String.format(
                        "Limite de 30 jours ouvrables atteinte. Vous avez déjà %d jour(s) réservé(s) et tentez d'en ajouter %d.",
                        totalActiveReservations, numberOfWorkingDaysInRequest
                ));
            }
        }
    }

    private long countAllActiveWorkingDays(UUID userId) {
        LocalDate today = LocalDate.now();

        List<Reservation> activeReservations = reservationRepository
                .findActiveReservationsByUser(userId).stream()
                .filter(r -> !r.getStartDateTime().toLocalDate().isBefore(today))
                .collect(Collectors.toList());

        return activeReservations.stream()
                .map(r -> r.getStartDateTime().toLocalDate())
                .distinct()
                .filter(date -> date.getDayOfWeek() != DayOfWeek.SATURDAY
                        && date.getDayOfWeek() != DayOfWeek.SUNDAY)
                .count();
    }

    private long countActiveWorkingDays(UUID userId, LocalDate fromDate, LocalDate toDate) {
        List<Reservation> activeReservations = reservationRepository
                .findActiveReservationsByUser(userId).stream()
                .filter(r -> !r.getStartDateTime().toLocalDate().isBefore(fromDate))
                .filter(r -> !r.getStartDateTime().toLocalDate().isAfter(toDate))
                .collect(Collectors.toList());

        // Compter les jours ouvrables uniques
        return activeReservations.stream()
                .map(r -> r.getStartDateTime().toLocalDate())
                .distinct()
                .filter(date -> date.getDayOfWeek() != DayOfWeek.SATURDAY
                        && date.getDayOfWeek() != DayOfWeek.SUNDAY)
                .count();
    }

    private List<LocalDate> generateWorkingDays(LocalDate start, LocalDate end) {
        return start.datesUntil(end.plusDays(1))
                .filter(date -> date.getDayOfWeek() != DayOfWeek.SATURDAY
                        && date.getDayOfWeek() != DayOfWeek.SUNDAY)
                .collect(Collectors.toList());
    }

    private ParkingSpot findAvailableSpot(LocalDate date, ReservationDTO dto) {
        List<ParkingSpot> availableSpots;

        if (dto.getNeedsElectricCharger()) {
            availableSpots = parkingSpotRepository.findAvailableElectricSpots(date, dto.getTimeSlot());
        } else {
            availableSpots = parkingSpotRepository.findAvailableSpots(date, dto.getTimeSlot());
        }

        if (dto.getSpotId() != null) {
            // Vérifier si la place demandée est disponible
            return availableSpots.stream()
                    .filter(spot -> spot.getSpotId().equals(dto.getSpotId()))
                    .findFirst()
                    .orElse(null);
        }

        // Attribution automatique
        return availableSpots.isEmpty() ? null : availableSpots.get(0);
    }

    private Reservation createDayReservation(User user, ParkingSpot spot,
                                             LocalDate date, ReservationDTO dto, String groupId) {
        Reservation reservation = new Reservation();
        reservation.setUser(user);
        reservation.setParkingSpot(spot);
        reservation.setGroupId(groupId);

        LocalTime startTime = "MORNING".equals(dto.getTimeSlot()) ? LocalTime.of(8, 0) :
                "AFTERNOON".equals(dto.getTimeSlot()) ? LocalTime.of(14, 0) :
                        LocalTime.of(8, 0); // FULL_DAY

        LocalTime endTime = "MORNING".equals(dto.getTimeSlot()) ? LocalTime.of(12, 0) :
                "AFTERNOON".equals(dto.getTimeSlot()) ? LocalTime.of(18, 0) :
                        LocalTime.of(18, 0); // FULL_DAY

        reservation.setStartDateTime(date.atTime(startTime));
        reservation.setEndDateTime(date.atTime(endTime));
        reservation.setStatus(ReservationStatus.ACTIVE);

        return reservation;
    }

    @Transactional
    public void cancelReservation(UUID userId, UUID reservationId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new BusinessException("Réservation non trouvée"));

        if (!reservation.getUser().getUserId().equals(userId)) {
            throw new BusinessException("Vous ne pouvez annuler que vos propres réservations");
        }

        if (reservation.getStatus() != ReservationStatus.ACTIVE) {
            throw new BusinessException("Cette réservation ne peut pas être annulée");
        }

        reservation.setStatus(ReservationStatus.CANCELLED_BY_USER);
        reservation.setCanceledAt(LocalDateTime.now());
        reservationRepository.save(reservation);

        emailQueueService.queueReservationCancellation(
                reservation.getUser().getUsername(),
                reservation.getParkingSpot().getSpotId(),
                reservation.getStartDateTime().toLocalDate().toString()
        );

        log.info("Réservation {} annulée par l'utilisateur", reservationId);
    }

    @Transactional
    public void cancelReservationGroup(UUID userId, String groupId) {
        List<Reservation> groupReservations = reservationRepository.findByGroupIdAndUserId(groupId, userId);

        for (Reservation reservation : groupReservations) {
            if (reservation.getStatus() == ReservationStatus.ACTIVE) {
                reservation.setStatus(ReservationStatus.CANCELLED_BY_USER);
                reservation.setCanceledAt(LocalDateTime.now());
            }
        }

        reservationRepository.saveAll(groupReservations);
        log.info("Groupe de réservations {} annulé", groupId);
    }

    @Transactional
    public ReservationResponseDTO checkIn(UUID userId, CheckInDTO dto) {
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();

        String currentTimeSlot = now.isBefore(LocalTime.of(14, 0)) ? "MORNING" : "AFTERNOON";

        Reservation reservation = reservationRepository.findActiveReservationBySpotAndDateTime(
                dto.getSpotId(), today, currentTimeSlot);

        if (reservation == null) {
            throw new BusinessException("Aucune réservation active trouvée pour cette place");
        }

        if (!reservation.getUser().getUserId().equals(userId)) {
            throw new BusinessException("Cette réservation ne vous appartient pas");
        }

        if (reservation.getCheckInTime() != null) {
            throw new BusinessException("Check-in déjà effectué");
        }

        reservation.setCheckInTime(LocalDateTime.now());
        reservation.setStatus(ReservationStatus.CHECKED_IN);

        Reservation saved = reservationRepository.save(reservation);
        log.info("Check-in effectué pour la réservation {}", saved.getReservationId());

        return convertToResponseDTO(saved);
    }

    @Transactional(readOnly = true)
    public List<ReservationResponseDTO> getUserReservations(UUID userId) {
        return reservationRepository.findAllReservationsByUser(userId)
                .stream()
                .map(this::convertToResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ReservationResponseDTO> getUserActiveReservations(UUID userId) {
        return reservationRepository.findActiveReservationsByUser(userId)
                .stream()
                .map(this::convertToResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void expireReservationsAt11AM() {
        LocalDate today = LocalDate.now();
        List<Reservation> reservationsToExpire = reservationRepository
                .findReservationsNeedingCheckIn(today);

        log.info("Traitement de {} réservations non confirmées", reservationsToExpire.size());

        for (Reservation reservation : reservationsToExpire) {
            reservation.setStatus(ReservationStatus.EXPIRED);
            reservation.setCanceledAt(LocalDateTime.now());
        }

        reservationRepository.saveAll(reservationsToExpire);

        // Optionnel : envoyer des notifications
        reservationsToExpire.forEach(r -> {
            log.info("Réservation {} expirée pour non check-in", r.getReservationId());
        });
    }

    // Ajouter dans ReservationService.java

    public UUID getUserIdByUsername(String username) {
        User user = userRepository.findByUsername(username);
        if (user == null) {
            throw new BusinessException("Utilisateur non trouvé: " + username);
        }
        return user.getUserId();
    }

    @Transactional(readOnly = true)
    public List<ReservationResponseDTO> getUserReservationsByDateRange(UUID userId, LocalDate startDate, LocalDate endDate) {
        return reservationRepository.findReservationsByUserAndDateRange(userId, startDate, endDate)
                .stream()
                .map(this::convertToResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ReservationResponseDTO> getAllReservationsHistory(LocalDate startDate, LocalDate endDate, String status) {
        List<Reservation> reservations;

        if (status != null && !status.isEmpty() && !status.equalsIgnoreCase("ALL")) {
            try {
                ReservationStatus reservationStatus = ReservationStatus.valueOf(status.toUpperCase());
                reservations = reservationRepository.findReservationsByStatusInPeriod(startDate, endDate, reservationStatus);
            } catch (IllegalArgumentException e) {
                log.warn("Status invalide fourni: {}", status);
                // Retourner une liste vide au lieu de lancer une exception
                return new ArrayList<>();
            }
        } else {
            // Si pas de status ou status = "ALL", récupérer toutes les réservations
            reservations = reservationRepository.findAllReservationsInPeriod(startDate, endDate);
        }

        return reservations.stream()
                .map(this::convertToResponseDTO)
                .collect(Collectors.toList());
    }

    private ReservationResponseDTO convertToResponseDTO(Reservation reservation) {
        ReservationResponseDTO dto = new ReservationResponseDTO();
        dto.setReservationId(reservation.getReservationId());
        dto.setSpotId(reservation.getParkingSpot().getSpotId());
        dto.setReservationDate(reservation.getStartDateTime().toLocalDate());

        LocalTime startTime = reservation.getStartDateTime().toLocalTime();
        String timeSlot = startTime.equals(LocalTime.of(8, 0)) &&
                reservation.getEndDateTime().toLocalTime().equals(LocalTime.of(18, 0)) ? "FULL_DAY" :
                startTime.isBefore(LocalTime.of(13, 0)) ? "MORNING" : "AFTERNOON";
        dto.setTimeSlot(timeSlot);

        dto.setStatus(reservation.getStatus().toString());
        dto.setCheckInTime(reservation.getCheckInTime());
        dto.setCreatedAt(reservation.getCreatedAt());
        dto.setUserName(reservation.getUser().getFirstName());
        dto.setGroupId(reservation.getGroupId());

        return dto;
    }

    @Transactional
    public void cancelReservationAsSecretary(UUID reservationId, String reason) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new BusinessException("Réservation non trouvée"));

        if (reservation.getStatus() != ReservationStatus.ACTIVE) {
            throw new BusinessException("Cette réservation ne peut pas être annulée");
        }

        reservation.setStatus(ReservationStatus.CANCELLED_BY_ADMIN);
        reservation.setCanceledAt(LocalDateTime.now());
        reservation.setCancellationReason(reason); // Ajouter ce champ dans l'entité si nécessaire

        Reservation saved = reservationRepository.save(reservation);

        // Envoyer email à l'utilisateur
        emailQueueService.queueReservationCancellation(
                reservation.getUser().getUsername(),
                reservation.getParkingSpot().getSpotId(),
                reservation.getStartDateTime().toLocalDate().toString()
        );

        log.info("Réservation {} annulée par la secrétaire. Raison: {}", reservationId, reason);
    }

    @Transactional
    public ReservationResponseDTO modifyReservationAsSecretary(UUID reservationId, ModifyReservationDTO modifyDTO) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new BusinessException("Réservation non trouvée"));

        if (reservation.getStatus() != ReservationStatus.ACTIVE) {
            throw new BusinessException("Seules les réservations actives peuvent être modifiées");
        }

        // Vérifier si la nouvelle place est disponible
        if (modifyDTO.getNewSpotId() != null && !modifyDTO.getNewSpotId().equals(reservation.getParkingSpot().getSpotId())) {
            ParkingSpot newSpot = parkingSpotRepository.findById(modifyDTO.getNewSpotId())
                    .orElseThrow(() -> new BusinessException("Place non trouvée"));

            // Vérifier disponibilité
            boolean isAvailable = reservationRepository.findActiveReservationBySpotAndDateTime(
                    modifyDTO.getNewSpotId(),
                    reservation.getStartDateTime().toLocalDate(),
                    reservation.getStartDateTime().toLocalTime().isBefore(LocalTime.of(14, 0)) ? "MORNING" : "AFTERNOON"
            ) == null;

            if (!isAvailable) {
                throw new BusinessException("La nouvelle place n'est pas disponible");
            }

            reservation.setParkingSpot(newSpot);
        }

        // Modifier la date si nécessaire
        if (modifyDTO.getNewDate() != null) {
            LocalTime startTime = reservation.getStartDateTime().toLocalTime();
            LocalTime endTime = reservation.getEndDateTime().toLocalTime();

            reservation.setStartDateTime(modifyDTO.getNewDate().atTime(startTime));
            reservation.setEndDateTime(modifyDTO.getNewDate().atTime(endTime));
        }

        Reservation saved = reservationRepository.save(reservation);

        log.info("Réservation {} modifiée par la secrétaire", reservationId);

        return convertToResponseDTO(saved);
    }

    @Transactional
    public ReservationResponseDTO modifyReservation(UUID userId, UUID reservationId, ModifyReservationDTO modifyDTO) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new BusinessException("Réservation non trouvée"));

        if (!reservation.getUser().getUserId().equals(userId)) {
            throw new BusinessException("Vous ne pouvez modifier que vos propres réservations");
        }

        if (reservation.getStatus() != ReservationStatus.ACTIVE) {
            throw new BusinessException("Seules les réservations actives peuvent être modifiées");
        }

        if (reservation.getStartDateTime().toLocalDate().isBefore(LocalDate.now())) {
            throw new BusinessException("Impossible de modifier une réservation passée");
        }

        boolean isModified = false;

        if (modifyDTO.getNewSpotId() != null && !modifyDTO.getNewSpotId().equals(reservation.getParkingSpot().getSpotId())) {
            ParkingSpot newSpot = parkingSpotRepository.findById(modifyDTO.getNewSpotId())
                    .orElseThrow(() -> new BusinessException("Nouvelle place non trouvée"));

            String timeSlot = reservation.getStartDateTime().toLocalTime().equals(LocalTime.of(8, 0)) ? "MORNING" : "AFTERNOON";
            Reservation existingReservation = reservationRepository.findActiveReservationBySpotAndDateTime(
                    modifyDTO.getNewSpotId(),
                    reservation.getStartDateTime().toLocalDate(),
                    timeSlot
            );

            if (existingReservation != null && !existingReservation.getReservationId().equals(reservationId)) {
                throw new BusinessException("La nouvelle place n'est pas disponible pour ce créneau");
            }

            reservation.setParkingSpot(newSpot);
            isModified = true;
        }

        if (modifyDTO.getNewDate() != null && !modifyDTO.getNewDate().equals(reservation.getStartDateTime().toLocalDate())) {
            if (modifyDTO.getNewDate().getDayOfWeek() == DayOfWeek.SATURDAY ||
                    modifyDTO.getNewDate().getDayOfWeek() == DayOfWeek.SUNDAY) {
                throw new BusinessException("Les réservations ne sont possibles que les jours ouvrables");
            }

            if (modifyDTO.getNewDate().isBefore(LocalDate.now())) {
                throw new BusinessException("La nouvelle date ne peut pas être dans le passé");
            }

            // Vérifier la disponibilité à la nouvelle date
            String spotId = reservation.getParkingSpot().getSpotId();
            String timeSlot = reservation.getStartDateTime().toLocalTime().equals(LocalTime.of(8, 0)) ? "MORNING" : "AFTERNOON";

            Reservation conflictingReservation = reservationRepository.findActiveReservationBySpotAndDateTime(
                    spotId,
                    modifyDTO.getNewDate(),
                    timeSlot
            );

            if (conflictingReservation != null) {
                throw new BusinessException("Cette place n'est pas disponible à la nouvelle date");
            }

            // Mettre à jour les dates
            LocalTime startTime = reservation.getStartDateTime().toLocalTime();
            LocalTime endTime = reservation.getEndDateTime().toLocalTime();

            reservation.setStartDateTime(modifyDTO.getNewDate().atTime(startTime));
            reservation.setEndDateTime(modifyDTO.getNewDate().atTime(endTime));
            isModified = true;
        }

        if (!isModified) {
            throw new BusinessException("Aucune modification demandée");
        }

        Reservation saved = reservationRepository.save(reservation);

        // Envoyer un email de notification
        emailQueueService.queueReservationModification(
                reservation.getUser().getUsername(),
                saved.getParkingSpot().getSpotId(),
                saved.getStartDateTime().toLocalDate().toString(),
                saved.getStartDateTime().toLocalTime().equals(LocalTime.of(8, 0)) ? "MORNING" : "AFTERNOON"
        );

        log.info("Réservation {} modifiée par l'utilisateur", reservationId);

        return convertToResponseDTO(saved);
    }
}