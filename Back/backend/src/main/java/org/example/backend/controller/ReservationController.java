package org.example.backend.controller;

import org.example.backend.dto.CheckInDTO;
import org.example.backend.dto.ReservationDTO;
import org.example.backend.dto.ReservationResponseDTO;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;
    private final UserRepository userRepository;


    @PostMapping
    public ResponseEntity<ReservationResponseDTO> createReservation(@RequestBody ReservationDTO dto) {
        UUID userId = getCurrentUserId();

        if (dto.getSpotId() != null) {
            ReservationResponseDTO reservation = reservationService.createReservationWithSpecificSpot(userId, dto);
            return ResponseEntity.ok(reservation);
        } else {
            ReservationResponseDTO reservation = reservationService.createReservation(userId, dto);
            return ResponseEntity.ok(reservation);
        }
    }

    @GetMapping("/my")
    public ResponseEntity<List<ReservationResponseDTO>> getMyReservations() {
        UUID userId = getCurrentUserId();
        List<ReservationResponseDTO> reservations = reservationService.getUserReservations(userId);
        return ResponseEntity.ok(reservations);
    }

    @GetMapping("/my/active")
    public ResponseEntity<List<ReservationResponseDTO>> getMyActiveReservations() {
        UUID userId = getCurrentUserId();
        List<ReservationResponseDTO> reservations = reservationService.getUserActiveReservations(userId);
        return ResponseEntity.ok(reservations);
    }

    @DeleteMapping("/{reservationId}")
    public ResponseEntity<Void> cancelReservation(@PathVariable UUID reservationId) {
        UUID userId = getCurrentUserId();
        reservationService.cancelReservation(userId, reservationId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/checkin")
    public ResponseEntity<ReservationResponseDTO> checkIn(@RequestBody CheckInDTO dto) {
        UUID userId = getCurrentUserId();
        ReservationResponseDTO reservation = reservationService.checkIn(userId, dto);
        return ResponseEntity.ok(reservation);
    }

    @PostMapping("/admin/{targetUserId}")
    public ResponseEntity<ReservationResponseDTO> createReservationForUser(
            @PathVariable UUID targetUserId,
            @RequestBody ReservationDTO dto) {

        // Vérifier que l'utilisateur connecté est une secrétaire
        requireSecretaryRole();

        ReservationResponseDTO reservation = reservationService.createReservation(targetUserId, dto);
        return ResponseEntity.ok(reservation);
    }

    @GetMapping("/admin/{targetUserId}")
    public ResponseEntity<List<ReservationResponseDTO>> getUserReservations(@PathVariable UUID targetUserId) {
        requireSecretaryRole();

        List<ReservationResponseDTO> reservations = reservationService.getUserReservations(targetUserId);
        return ResponseEntity.ok(reservations);
    }

    @GetMapping("/admin/{targetUserId}/active")
    public ResponseEntity<List<ReservationResponseDTO>> getUserActiveReservations(@PathVariable UUID targetUserId) {
        requireSecretaryRole();

        List<ReservationResponseDTO> reservations = reservationService.getUserActiveReservations(targetUserId);
        return ResponseEntity.ok(reservations);
    }

    @DeleteMapping("/admin/{targetUserId}/{reservationId}")
    public ResponseEntity<Void> cancelReservationForUser(
            @PathVariable UUID targetUserId,
            @PathVariable UUID reservationId) {

        requireSecretaryRole();

        reservationService.cancelReservation(targetUserId, reservationId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/admin/{targetUserId}/checkin")
    public ResponseEntity<ReservationResponseDTO> checkInForUser(
            @PathVariable UUID targetUserId,
            @RequestBody CheckInDTO dto) {

        requireSecretaryRole();

        ReservationResponseDTO reservation = reservationService.checkIn(targetUserId, dto);
        return ResponseEntity.ok(reservation);
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        User user = userRepository.findByUsername(username);
        if (user == null) {
            throw new RuntimeException("Utilisateur non trouvé");
        }

        return user.getUserId();
    }

    private void requireSecretaryRole() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        User user = userRepository.findByUsername(username);
        if (user == null || !"SECRETARY".equals(user.getRole())) {
            throw new RuntimeException("Accès refusé : rôle secrétaire requis");
        }
    }
}