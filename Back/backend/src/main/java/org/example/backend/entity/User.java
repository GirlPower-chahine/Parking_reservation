package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "USERS")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "user_id")
    private UUID userId;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    private String firstName;

    private String role;

    @Column(nullable = false) // Ajout du champ isActive
    private Boolean isActive = true; // Statut actif/inactif de l'utilisateur

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false) // Ajouté pour le suivi des modifications
    private LocalDateTime updatedAt;

    @PrePersist // Méthode appelée avant la persistance initiale
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now(); // Initialise aussi updatedAt à la création
    }

    @PreUpdate // Méthode appelée avant chaque mise à jour
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now(); // Met à jour updatedAt à chaque modification
    }
}
