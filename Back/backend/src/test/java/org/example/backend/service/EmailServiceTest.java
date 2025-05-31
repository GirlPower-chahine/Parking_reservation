package org.example.backend.service;

import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.util.ReflectionTestUtils; // Pour injecter @Value

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class EmailServiceTest {

    @Mock
    private JavaMailSender mailSender;
    @Mock
    private MimeMessage mimeMessage; // Mock de MimeMessage

    @InjectMocks
    private EmailService emailService;

    private String fromEmail = "parking.app@example.com";

    @BeforeEach
    void setUp() {
        // Injecter la valeur de fromEmail car @Value n'est pas géré par Mockito
        ReflectionTestUtils.setField(emailService, "fromEmail", fromEmail);
        // Configurer le mock de mailSender pour retourner un mock de MimeMessage
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);
    }

    @Test
    void sendReservationConfirmation_shouldSendEmailSuccessfully() throws Exception {
        // GIVEN
        String email = "user@example.com";
        String spotId = "A01";
        String date = "2025-06-01";
        String timeSlot = "MORNING";

        // WHEN
        emailService.sendReservationConfirmation(email, spotId, date, timeSlot);

        // THEN
        // Vérifier que createMimeMessage a été appelé
        verify(mailSender, times(1)).createMimeMessage();
        // Vérifier que send a été appelé avec le MimeMessage créé
        verify(mailSender, times(1)).send(mimeMessage);

        // On ne peut pas facilement vérifier le contenu exact du MimeMessageHelper
        // sans des mocks plus complexes ou en capturant l'objet MimeMessageHelper.
        // Cependant, on peut vérifier que send a été appelé.
    }

    @Test
    void sendReservationCancellation_shouldSendEmailSuccessfully() throws Exception {
        // GIVEN
        String email = "user@example.com";
        String spotId = "B02";
        String date = "2025-06-02";

        // WHEN
        emailService.sendReservationCancellation(email, spotId, date);

        // THEN
        verify(mailSender, times(1)).createMimeMessage();
        verify(mailSender, times(1)).send(mimeMessage);
    }

    @Test
    void sendReservationReminder_shouldSendEmailSuccessfully() throws Exception {
        // GIVEN
        String email = "user@example.com";
        String spotId = "C03";
        String date = "2025-06-03";
        String timeSlot = "AFTERNOON";

        // WHEN
        emailService.sendReservationReminder(email, spotId, date, timeSlot);

        // THEN
        verify(mailSender, times(1)).createMimeMessage();
        verify(mailSender, times(1)).send(mimeMessage);
    }

    @Test
    void sendReservationConfirmation_shouldLogError_whenMailSenderThrowsException() throws Exception {
        // GIVEN
        String email = "user@example.com";
        String spotId = "A01";
        String date = "2025-06-01";
        String timeSlot = "MORNING";
        doThrow(new RuntimeException("Mail send error")).when(mailSender).send(any(MimeMessage.class));

        // WHEN
        emailService.sendReservationConfirmation(email, spotId, date, timeSlot);

        // THEN
        // Vérifier que send a été appelé, même s'il a échoué
        verify(mailSender, times(1)).send(mimeMessage);
        // Vous pouvez ajouter une vérification de log si vous utilisez un framework de log testable pour vérifier l'erreur
    }

    // TODO: Tester les méthodes create...EmailTemplate() séparément pour vérifier le contenu HTML généré.
    // Cela peut être fait en appelant directement la méthode privée via ReflectionTestUtils ou en la rendant publique/package-private pour le test.
}