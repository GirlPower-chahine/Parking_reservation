ADR-009: Stratégie de Tests
Date: 2025-01-27
Statut: Accepté
Décideurs: Équipe développement
Contexte
Le projet exige des "tests qui signifient quelque chose" pour garantir la qualité et éviter les régressions.
Problème
Définir une stratégie de tests complète et efficace.
Options Considérées
Tests Unitaires Uniquement
Inconvénients:

Pas de test d'intégration
Bugs en production possibles

Tests Complets (Pyramide de Tests)
Avantages:

Détection précoce des bugs
Confiance dans les déploiements
Documentation vivante

Décision
Nous implémentons une stratégie de tests pyramidale complète.
Backend:

Tests unitaires (JUnit 5 + Mockito)
Tests d'intégration (TestContainers)
Tests API (MockMvc)

Frontend:

Tests unitaires (flutter_test)
Tests widgets
Tests d'intégration end-to-end

Justification

Qualité: Détection précoce des régressions
Confiance: Déploiements sécurisés
Documentation: Tests comme spécifications
TestContainers: Tests avec vraie base de données
