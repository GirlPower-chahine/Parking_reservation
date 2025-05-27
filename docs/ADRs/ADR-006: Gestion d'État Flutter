ADR-006: Gestion d'État Flutter
Date: 2025-01-27
Statut: Accepté
Décideurs: Équipe développement
Contexte
Notre application Flutter doit gérer l'état de l'interface (réservations, authentification, navigation) de manière prévisible et testable.
Problème
Choisir une solution de state management adaptée à la complexité de notre application.
Options Considérées
Option 1: setState() Simple
Avantages:

Intégré à Flutter
Simplicité

Inconvénients:

Pas scalable
Difficile à tester
Pas de séparation des préoccupations

Option 2: Provider
Avantages:

Recommandé par Google
Simplicité relative

Inconvénients:

Pas assez structuré pour logique complexe
Tests difficiles

Option 3: BLoC Pattern
Avantages:

Séparation UI/Business Logic
Très testable
Gestion d'état prévisible
Réactif avec Streams

Inconvénients:

Courbe d'apprentissage

Décision
Nous utilisons BLoC Pattern avec Repository Pattern.
Justification

Testabilité: Logique métier séparée de l'UI
Prévisibilité: États d'application clairs
Architecture: S'aligne avec Clean Architecture
Réactivité: Parfait pour temps réel (réservations)
