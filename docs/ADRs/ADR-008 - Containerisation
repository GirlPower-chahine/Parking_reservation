ADR-008: Containerisation
Date: 2025-01-27
Statut: Accepté
Décideurs: Équipe développement
Contexte
Le projet exige une containerisation obligatoire pour faciliter le déploiement et les contributions équipe.
Problème
Définir la stratégie de containerisation optimale.
Options Considérées
Option 1: Containers Séparés

Spring Boot Container
MySQL Container
Nginx Container (pour Flutter Web)

Option 2: Container Unique
Inconvénients:

Violé le principe de responsabilité unique
Debugging complexe

Décision
Nous utilisons containers séparés avec Docker Compose.
Justification

Isolation: Chaque service dans son container
Développement: Docker Compose pour orchestration locale
Production: Déploiement flexible
Onboarding: Configuration reproductible
