# ADR-010: Architecture Hexagonale

---

## Informations Générales

| **Attribut** | **Valeur** |
|--------------|------------|
| **Date** | 2025-01-27 |
| **Statut** | **Accepté** |
| **Décideurs** | Équipe développement |

---

## Contexte

Nous voulons une architecture qui isole parfaitement la logique métier des détails techniques.

---

## Problème

**Choisir entre architecture en couches ou architecture hexagonale.**

---

## Options Considérées

### Option 1: Architecture en Couches

<table>
<tr>
<td width="50%">

**Avantages**
-

</td>
<td width="50%">

**Inconvénients**
- Couplage fort entre couches
- Difficile à tester

</td>
</tr>
</table>

---

### Option 2: Architecture Hexagonale **[CHOISI]**

<table>
<tr>
<td width="50%">

**Avantages**
- Logique métier totalement isolée
- Testabilité maximale
- Flexibilité technologique

</td>
<td width="50%">

**Inconvénients**
-

</td>
</tr>
</table>

---

## Décision

**Architecture hexagonale (Ports & Adapters)** est adoptée.

### Structure
- **Domain Core:** Entités, Services métier, Règles business
- **Ports:** Interfaces d'entrée et sortie
- **Adapters:** Implémentations techniques (REST, JPA, etc.)

---

## Justification

**Testabilité:** Logique métier testable sans dépendances

**Flexibilité:** Changement d'adaptateurs sans impact métier

**Maintenabilité:** Séparation claire des responsabilités

**Évolution:** Facilite les changements technologiques
