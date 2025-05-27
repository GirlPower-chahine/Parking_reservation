ADR-004: Stratégie d'Authentification
Date: 2025-01-27
Statut: Accepté
Décideurs: Équipe développement
Contexte
Notre système nécessite une authentification sécurisée avec trois profils (Employé, Manager, Secrétaire) ayant des autorisations différentes. L'authentification doit fonctionner sur Web et mobile.
Problème
Choisir une solution d'authentification sécurisée, scalable, et compatible multi-plateforme.
Options Considérées
Option 1: Sessions Serveur
Avantages:

Simple à implémenter
Révocation immédiate possible

Inconvénients:

 Problème de scalabilité
Stockage serveur requis
Complexe avec applications mobiles

Option 2: JWT (JSON Web Tokens)
Avantages:

Stateless (pas de stockage serveur)
Excellent support multi-plateforme
Claims pour autorisations
 Standard industrie

Inconvénients:

 Révocation complexe
 Taille des tokens

Décision
Nous utilisons JWT avec Spring Security.
Justification

Multi-plateforme: Fonctionne naturellement sur Web/Mobile
Scalabilité: Stateless, pas de stockage sessions
Sécurité: Spring Security battle-tested
Autorisations: Claims JWT pour gérer les 3 profils
