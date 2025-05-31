package org.example.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.backend.configuration.RabbitMQConfig;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class EmailConsumer {

    private final EmailService emailService;

    @RabbitListener(queues = RabbitMQConfig.EMAIL_QUEUE)
    public void processEmailMessage(Map<String, String> emailData) {
        try {
            String type = emailData.get("type");
            String email = emailData.get("email");

            log.info("🔄 Traitement message email type: {} pour: {}", type, email);

            switch (type) {
                case "reservation_confirmation":
                    emailService.sendReservationConfirmation(
                            email,
                            emailData.get("spotId"),
                            emailData.get("date"),
                            emailData.get("timeSlot")
                    );
                    log.info("✅ Email de confirmation traité pour: {}", email);
                    break;

                case "reservation_cancellation":
                    emailService.sendReservationCancellation(
                            email,
                            emailData.get("spotId"),
                            emailData.get("date")
                    );
                    log.info("✅ Email d'annulation traité pour: {}", email);
                    break;

                case "reservation_reminder":
                    emailService.sendReservationReminder(
                            email,
                            emailData.get("spotId"),
                            emailData.get("date"),
                            emailData.get("timeSlot")
                    );
                    log.info("✅ Email de rappel traité pour: {}", email);
                    break;

                default:
                    log.warn("⚠️ Type d'email non reconnu: {}", type);
            }

        } catch (Exception e) {
            log.error("❌ Erreur traitement message email: {}", e.getMessage(), e);
            // Optionnel : remettre le message en queue ou l'envoyer vers une dead letter queue
        }
    }
}