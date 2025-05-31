package org.example.backend.controller;

import org.example.backend.dto.*;
import org.example.backend.service.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;

    @PostMapping
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'SECRETARY', 'MANAGER')")
    public ResponseEntity<List<ReservationResponseDTO>> createReservation(
            @Valid @RequestBody ReservationDTO dto,
            @AuthenticationPrincipal UserDetails userDetails) {

        UUID userId = getUserIdFromUsername(userDetails.getUsername());
        List<ReservationResponseDTO> reservations = reservationService.createReservation(userId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(reservations);
    }

    @PostMapping("/user/{targetUserId}")
    @PreAuthorize("hasRole('SECRETARY')")
    public ResponseEntity<List<ReservationResponseDTO>> createReservationForUser(
            @PathVariable UUID targetUserId,
            @Valid @RequestBody ReservationDTO dto) {

        List<ReservationResponseDTO> reservations = reservationService.createReservation(targetUserId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(reservations);
    }

    @GetMapping("/my")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'SECRETARY', 'MANAGER')")
    public ResponseEntity<List<ReservationResponseDTO>> getMyReservations(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        UUID userId = getUserIdFromUsername(userDetails.getUsername());
        List<ReservationResponseDTO> reservations = startDate != null && endDate != null ?
                reservationService.getUserReservationsByDateRange(userId, startDate, endDate) :
                reservationService.getUserReservations(userId);
        return ResponseEntity.ok(reservations);
    }

    @GetMapping("/my/active")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'SECRETARY', 'MANAGER')")
    public ResponseEntity<List<ReservationResponseDTO>> getMyActiveReservations(
            @AuthenticationPrincipal UserDetails userDetails) {

        UUID userId = getUserIdFromUsername(userDetails.getUsername());
        List<ReservationResponseDTO> reservations = reservationService.getUserActiveReservations(userId);
        return ResponseEntity.ok(reservations);
    }

    @GetMapping("/user/{targetUserId}")
    @PreAuthorize("hasRole('SECRETARY') or (hasAnyRole('EMPLOYEE', 'MANAGER') and #targetUserId == authentication.principal.userId)")
    public ResponseEntity<List<ReservationResponseDTO>> getUserReservations(
            @PathVariable UUID targetUserId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        List<ReservationResponseDTO> reservations = startDate != null && endDate != null ?
                reservationService.getUserReservationsByDateRange(targetUserId, startDate, endDate) :
                reservationService.getUserReservations(targetUserId);
        return ResponseEntity.ok(reservations);
    }

    @GetMapping("/user/{targetUserId}/active")
    @PreAuthorize("hasRole('SECRETARY') or (hasAnyRole('EMPLOYEE', 'MANAGER') and #targetUserId == authentication.principal.userId)")
    public ResponseEntity<List<ReservationResponseDTO>> getUserActiveReservations(
            @PathVariable UUID targetUserId) {

        List<ReservationResponseDTO> reservations = reservationService.getUserActiveReservations(targetUserId);
        return ResponseEntity.ok(reservations);
    }

    @DeleteMapping("/{reservationId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'SECRETARY', 'MANAGER')")
    public ResponseEntity<Void> cancelReservation(
            @PathVariable UUID reservationId,
            @AuthenticationPrincipal UserDetails userDetails) {

        UUID userId = getUserIdFromUsername(userDetails.getUsername());
        reservationService.cancelReservation(userId, reservationId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/group/{groupId}")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'SECRETARY', 'MANAGER')")
    public ResponseEntity<Void> cancelReservationGroup(
            @PathVariable String groupId,
            @AuthenticationPrincipal UserDetails userDetails) {

        UUID userId = getUserIdFromUsername(userDetails.getUsername());
        reservationService.cancelReservationGroup(userId, groupId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/user/{targetUserId}/{reservationId}")
    @PreAuthorize("hasRole('SECRETARY')")
    public ResponseEntity<Void> cancelReservationForUser(
            @PathVariable UUID targetUserId,
            @PathVariable UUID reservationId) {

        reservationService.cancelReservation(targetUserId, reservationId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/checkin")
    @PreAuthorize("hasAnyRole('EMPLOYEE', 'SECRETARY', 'MANAGER')")
    public ResponseEntity<ReservationResponseDTO> checkIn(
            @Valid @RequestBody CheckInDTO dto,
            @AuthenticationPrincipal UserDetails userDetails) {

        UUID userId = getUserIdFromUsername(userDetails.getUsername());
        ReservationResponseDTO reservation = reservationService.checkIn(userId, dto);
        return ResponseEntity.ok(reservation);
    }

    @PostMapping("/user/{targetUserId}/checkin")
    @PreAuthorize("hasRole('SECRETARY')")
    public ResponseEntity<ReservationResponseDTO> checkInForUser(
            @PathVariable UUID targetUserId,
            @Valid @RequestBody CheckInDTO dto) {

        ReservationResponseDTO reservation = reservationService.checkIn(targetUserId, dto);
        return ResponseEntity.ok(reservation);
    }

    @GetMapping("/history")
    @PreAuthorize("hasAnyRole('SECRETARY', 'MANAGER')")
    public ResponseEntity<List<ReservationResponseDTO>> getAllReservationsHistory(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String status) {

        List<ReservationResponseDTO> reservations = reservationService.getAllReservationsHistory(startDate, endDate, status);
        return ResponseEntity.ok(reservations);
    }

    // Méthode helper pour obtenir l'userId depuis le username
    private UUID getUserIdFromUsername(String username) {
        // Cette méthode devrait être implémentée dans un service
        // Pour l'instant, elle est simplifiée
        return reservationService.getUserIdByUsername(username);
    }

    @PostMapping("/secretary/create-for-user")
    @PreAuthorize("hasRole('SECRETARY')")
    public ResponseEntity<List<ReservationResponseDTO>> createReservationForUser(
            @RequestParam String userEmail,
            @RequestBody ReservationDTO reservationDTO) {

        UUID userId = reservationService.getUserIdByUsername(userEmail);
        List<ReservationResponseDTO> reservations = reservationService.createReservation(userId, reservationDTO);
        return ResponseEntity.ok(reservations);
    }

    @DeleteMapping("/secretary/cancel/{reservationId}")
    @PreAuthorize("hasRole('SECRETARY')")
    public ResponseEntity<Void> cancelReservationAsSecretary(
            @PathVariable UUID reservationId,
            @RequestParam String reason) {

        reservationService.cancelReservationAsSecretary(reservationId, reason);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/secretary/modify/{reservationId}")
    @PreAuthorize("hasRole('SECRETARY')")
    public ResponseEntity<ReservationResponseDTO> modifyReservationAsSecretary(
            @PathVariable UUID reservationId,
            @RequestBody ModifyReservationDTO modifyDTO) {

        ReservationResponseDTO modified = reservationService.modifyReservationAsSecretary(reservationId, modifyDTO);
        return ResponseEntity.ok(modified);
    }

    @GetMapping("/secretary/user-reservations")
    @PreAuthorize("hasRole('SECRETARY')")
    public ResponseEntity<List<ReservationResponseDTO>> getUserReservationsAsSecretary(
            @RequestParam String userEmail) {

        UUID userId = reservationService.getUserIdByUsername(userEmail);
        List<ReservationResponseDTO> reservations = reservationService.getUserActiveReservations(userId);
        return ResponseEntity.ok(reservations);
    }

    @PutMapping("/{reservationId}")
    @PreAuthorize("hasRole('EMPLOYEE') or hasRole('SECRETARY') or hasRole('MANAGER')")
    public ResponseEntity<ReservationResponseDTO> modifyReservation(
            @PathVariable UUID reservationId,
            @RequestBody ModifyReservationDTO modifyDTO,
            Authentication authentication) {

        UUID userId = reservationService.getUserIdByUsername(authentication.getName());
        ReservationResponseDTO modified = reservationService.modifyReservation(userId, reservationId, modifyDTO);
        return ResponseEntity.ok(modified);
    }


}