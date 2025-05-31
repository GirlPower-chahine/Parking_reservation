package org.example.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.backend.configuration.RabbitMQConfig;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailQueueService {

    private final RabbitTemplate rabbitTemplate;

    public void queueReservationConfirmation(String email, String spotId, String date, String timeSlot) {
        Map<String, String> emailData = Map.of(
                "type", "reservation_confirmation",
                "email", email,
                "spotId", spotId,
                "date", date,
                "timeSlot", timeSlot
        );

        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EXCHANGE,
                    RabbitMQConfig.EMAIL_ROUTING_KEY,
                    emailData
            );
            log.info("Email de confirmation mis en queue pour: {}", email);
        } catch (Exception e) {
            log.error("Erreur mise en queue email: {}", e.getMessage());
        }
    }

    public void queueReservationCancellation(String email, String spotId, String date) {
        Map<String, String> emailData = Map.of(
                "type", "reservation_cancellation",
                "email", email,
                "spotId", spotId,
                "date", date
        );

        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EXCHANGE,
                    RabbitMQConfig.EMAIL_ROUTING_KEY,
                    emailData
            );
            log.info("Email d'annulation mis en queue pour: {}", email);
        } catch (Exception e) {
            log.error("Erreur mise en queue email d'annulation: {}", e.getMessage());
        }
    }

    public void queueReservationReminder(String email, String spotId, String date, String timeSlot) {
        Map<String, String> emailData = Map.of(
                "type", "reservation_reminder",
                "email", email,
                "spotId", spotId,
                "date", date,
                "timeSlot", timeSlot
        );

        try {
            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EXCHANGE,
                    RabbitMQConfig.EMAIL_ROUTING_KEY,
                    emailData
            );
            log.info("Email de rappel mis en queue pour: {}", email);
        } catch (Exception e) {
            log.error("Erreur mise en queue rappel: {}", e.getMessage());
        }
    }
}