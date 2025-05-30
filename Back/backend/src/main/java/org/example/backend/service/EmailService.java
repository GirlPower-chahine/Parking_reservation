package org.example.backend.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class EmailService {

    public void sendReservationConfirmation(String email, String spotId, String date, String timeSlot) {
        log.info("=== EMAIL DE CONFIRMATION ===");
        log.info("Destinataire: {}", email);
        log.info("Place réservée: {}", spotId);
        log.info("Date: {}", date);
        log.info("Créneau: {}", timeSlot);
        log.info("=============================");

        // Exemple avec Spring Mail :
        // mailSender.send(createReservationEmail(email, spotId, date, timeSlot));
    }

    public void sendReservationCancellation(String email, String spotId, String date) {
        log.info("=== EMAIL D'ANNULATION ===");
        log.info("Destinataire: {}", email);
        log.info("Place annulée: {}", spotId);
        log.info("Date: {}", date);
        log.info("===========================");
    }

    public void sendReservationReminder(String email, String spotId, String date, String timeSlot) {
        log.info("=== RAPPEL DE RÉSERVATION ===");
        log.info("Destinataire: {}", email);
        log.info("N'oubliez pas votre réservation place {} le {} ({})", spotId, date, timeSlot);
        log.info("=============================");
    }
}