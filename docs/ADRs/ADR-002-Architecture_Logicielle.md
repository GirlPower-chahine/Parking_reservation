# ADR-002: Choix de l'Architecture Backend

---

## Informations Générales

| **Attribut** | **Valeur** |
|--------------|------------|
| **Date** | 2025-01-27 |
| **Statut** | **Accepté** |
| **Décideurs** | Équipe développement |

---

## Contexte

Notre **système de parking** nécessite une architecture claire pour gérer la complexité métier (réservations, utilisateurs, analytics) tout en restant maintenable par une équipe réduite.

### Enjeux architecturaux
- Gestion de la logique métier complexe
- Maintien de la qualité avec équipe réduite
- Évolutivité du système
- Facilitation des tests

---

## Problème

**Choisir une architecture qui sépare clairement les préoccupations, facilite les tests, et permet une évolution future sans refactoring majeur.**

---

## Options Considérées

### Option 1: Architecture en Couches Traditionnelle

<table>
<tr>
<td width="50%">

**Avantages**
- Simple à comprendre
- Bien supportée par Spring Boot
- Courbe d'apprentissage faible

</td>
<td width="50%">

**Inconvénients**
- Couplage fort entre couches
- Difficile à tester unitairement
- Logique métier dispersée

</td>
</tr>
</table>

---

### Option 2: Clean Architecture + DDD **[CHOISI]**

<table>
<tr>
<td width="50%">

**Avantages**
- Séparation claire des responsabilités
- Logique métier indépendante des frameworks
- Testabilité maximale
- Évolutivité et maintenabilité
- Alignement avec les bonnes pratiques enseignées

</td>
<td width="50%">

**Inconvénients**
- Complexité initiale plus élevée
- Plus de fichiers et interfaces

</td>
</tr>
</table>

---

## Décision

**Clean Architecture avec Domain Driven Design** est adoptée comme architecture backend.

---

## Justification

### Qualité
Architecture **recommandée** pour projets avec logique métier complexe

### Tests
**Facilite les tests unitaires** de la logique métier

### Évolution
Permet **changements technologiques** sans impact métier

### Apprentissage
**Applique les concepts** vus en cours

---

## Structure Proposée

| **Couche** | **Responsabilité** |
|------------|-------------------|
| **Domain** | Entités métier, règles business, interfaces |
| **Application** | Cas d'usage, orchestration |
| **Infrastructure** | Implémentations techniques, base de données |
| **Presentation** | Controllers, DTOs, API REST |

---

## Bénéfices Attendus

| **Aspect** | **Amélioration** |
|------------|------------------|
| **Testabilité** | Tests unitaires isolés de l'infrastructure |
| **Maintenabilité** | Séparation claire des responsabilités |
| **Évolutivité** | Changements techniques sans impact métier |
| **Qualité du code** | Respect des principes SOLID |
