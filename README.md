ADRs Flutter + Spring Boot :

ADR-001: Application Mobile Flutter

Justification du choix mobile-first pour la gestion de parking
Avantages : QR code natif, notifications push, GPS, performance native
Cross-platform avec un seul codebase

ADR-002: Clean Architecture + DDD

Séparation claire des responsabilités
Business logic indépendante du framework
Testabilité et maintenabilité améliorées

ADR-003: Stack Technique Flutter + Spring Boot

Frontend : Flutter/Dart pour performance native mobile
Backend : Java 17+ Spring Boot 3.x pour robustesse enterprise
Base de données : Mysqld
Message Queue : RabbitMQ pour fiabilité
Cache : Redis pour performance

ADR-004: Authentification JWT + Spring Security + Flutter Secure Storage

Spring Security pour le backend (battle-tested)
Flutter Secure Storage pour sécurité mobile (Keychain/Keystore)
Support biométrie native

ADR-005: Modular Monolith

Single database avec séparation par domaines
Simplicité opérationnelle vs complexité microservices
ACID transactions cross-domain

ADR-006: BLoC Pattern + Repository Pattern

State management prévisible pour Flutter
Séparation UI/Business Logic
Architecture testable et réactive
