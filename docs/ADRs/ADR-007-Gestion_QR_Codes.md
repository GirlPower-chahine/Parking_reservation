ADR-007: Gestion QR Codes
Date: 2025-01-27
Statut: Accepté
Décideurs: Équipe développement
Contexte
Chaque place de parking (60 places A01-F10) doit avoir un QR code pour permettre le check-in. Le système doit gérer la génération, validation, et libération automatique des places.
Problème
Choisir entre génération interne ou service externe pour les QR codes.
Options Considérées
Option 1: Génération Interne
Avantages:

Pas de dépendance externe
Contrôle total

Inconvénients:

Code métier pollué
Maintenance supplémentaire
Pas notre cœur de métier

Option 2: Service Externe
Avantages:

Séparation des responsabilités
Service spécialisé plus fiable
Pas de maintenance QR code
Changement de provider facile

Inconvénients:

Dépendance externe
Coût potentiel

Décision
Nous utilisons un service externe pour la génération QR codes.
Justification

Focus métier: Concentration sur la logique de réservation
Fiabilité: Service spécialisé plus robuste
Architecture: Respecte la séparation des préoccupations
Évolution: Changement de provider sans impact métier
