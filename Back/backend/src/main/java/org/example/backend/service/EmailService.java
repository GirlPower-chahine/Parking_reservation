package org.example.backend.service;

import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    public void sendReservationConfirmation(String email, String spotId, String date, String timeSlot) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(email);
            helper.setSubject("🅿️ Confirmation de réservation - Place " + spotId);

            String htmlContent = createReservationEmailTemplate(spotId, date, timeSlot);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("✅ Email de confirmation envoyé à {}", email);

        } catch (Exception e) {
            log.error("❌ Erreur envoi email à {}: {}", email, e.getMessage());
        }
    }

    public void sendReservationCancellation(String email, String spotId, String date) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(email);
            helper.setSubject("❌ Annulation de réservation - Place " + spotId);

            String htmlContent = createCancellationEmailTemplate(spotId, date);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("✅ Email d'annulation envoyé à {}", email);

        } catch (Exception e) {
            log.error("❌ Erreur envoi email d'annulation: {}", e.getMessage());
        }
    }

    public void sendReservationReminder(String email, String spotId, String date, String timeSlot) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(email);
            helper.setSubject("⏰ Rappel - Réservation place " + spotId + " demain");

            String htmlContent = createReminderEmailTemplate(spotId, date, timeSlot);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("✅ Email de rappel envoyé à {}", email);

        } catch (Exception e) {
            log.error("❌ Erreur envoi rappel: {}", e.getMessage());
        }
    }

    private String createReservationEmailTemplate(String spotId, String date, String timeSlot) {
        return """
            <html>
            <body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
                <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    <div style="text-align: center; margin-bottom: 30px;">
                        <h1 style="color: #2196F3; margin: 0;">🅿️ ParkingApp</h1>
                    </div>
                    
                    <h2 style="color: #4CAF50; text-align: center;">✅ Réservation confirmée !</h2>
                    
                    <p style="font-size: 16px; line-height: 1.6;">Bonjour,</p>
                    <p style="font-size: 16px; line-height: 1.6;">Votre réservation a été confirmée avec succès.</p>
                    
                    <div style="background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); color: white; padding: 20px; border-radius: 10px; margin: 25px 0; text-align: center;">
                        <h3 style="margin: 0 0 15px 0; font-size: 18px;">📋 Détails de votre réservation</h3>
                        <div style="font-size: 16px;">
                            <p style="margin: 8px 0;"><strong>📍 Place :</strong> %s</p>
                            <p style="margin: 8px 0;"><strong>📅 Date :</strong> %s</p>
                            <p style="margin: 8px 0;"><strong>🕐 Créneau :</strong> %s</p>
                        </div>
                    </div>
                    
                    <div style="background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <h4 style="color: #856404; margin: 0 0 10px 0;">⚠️ Important - Check-in obligatoire</h4>
                        <p style="color: #856404; margin: 0; font-size: 14px;">
                            Vous devez effectuer votre <strong>check-in avant 11h00</strong> en scannant le QR code sur votre place.
                            <br>Sans check-in, votre réservation sera automatiquement annulée.
                        </p>
                    </div>
                    
                    <div style="text-align: center; margin: 30px 0;">
                        <p style="font-size: 16px; color: #666;">Bonne journée ! 🚗</p>
                        <p style="font-size: 14px; color: #999; font-style: italic;">L'équipe ParkingApp</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(spotId, date, timeSlot);
    }

    private String createCancellationEmailTemplate(String spotId, String date) {
        return """
            <html>
            <body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
                <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    <div style="text-align: center; margin-bottom: 30px;">
                        <h1 style="color: #2196F3; margin: 0;">🅿️ ParkingApp</h1>
                    </div>
                    
                    <h2 style="color: #f44336; text-align: center;">❌ Réservation annulée</h2>
                    
                    <p style="font-size: 16px; line-height: 1.6;">Bonjour,</p>
                    <p style="font-size: 16px; line-height: 1.6;">Votre réservation a été annulée.</p>
                    
                    <div style="background: #ffebee; border: 1px solid #f44336; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <p style="margin: 0;"><strong>📍 Place :</strong> %s</p>
                        <p style="margin: 5px 0 0 0;"><strong>📅 Date :</strong> %s</p>
                    </div>
                    
                    <p style="font-size: 16px; line-height: 1.6;">Vous pouvez effectuer une nouvelle réservation à tout moment via l'application.</p>
                    
                    <div style="text-align: center; margin: 30px 0;">
                        <p style="font-size: 14px; color: #999; font-style: italic;">L'équipe ParkingApp</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(spotId, date);
    }

    private String createReminderEmailTemplate(String spotId, String date, String timeSlot) {
        return """
            <html>
            <body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
                <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    <div style="text-align: center; margin-bottom: 30px;">
                        <h1 style="color: #2196F3; margin: 0;">🅿️ ParkingApp</h1>
                    </div>
                    
                    <h2 style="color: #ff9800; text-align: center;">⏰ Rappel de réservation</h2>
                    
                    <p style="font-size: 16px; line-height: 1.6;">Bonjour,</p>
                    <p style="font-size: 16px; line-height: 1.6;">N'oubliez pas votre réservation demain !</p>
                    
                    <div style="background: #fff3e0; border: 1px solid #ff9800; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <p style="margin: 0;"><strong>📍 Place :</strong> %s</p>
                        <p style="margin: 5px 0;"><strong>📅 Date :</strong> %s</p>
                        <p style="margin: 5px 0 0 0;"><strong>🕐 Créneau :</strong> %s</p>
                    </div>
                    
                    <div style="background: #e8f5e8; border: 1px solid #4CAF50; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <h4 style="color: #2e7d32; margin: 0 0 10px 0;">📱 Check-in obligatoire</h4>
                        <p style="color: #2e7d32; margin: 0; font-size: 14px;">
                            Scannez le QR code sur votre place <strong>avant 11h00</strong>
                        </p>
                    </div>
                    
                    <div style="text-align: center; margin: 30px 0;">
                        <p style="font-size: 14px; color: #999; font-style: italic;">L'équipe ParkingApp</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(spotId, date, timeSlot);
    }
}