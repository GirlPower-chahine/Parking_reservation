# ADR-006: Gestion d'État Flutter

---

## Informations Générales

| **Attribut** | **Valeur** |
|--------------|------------|
| **Date** | 2025-01-27 |
| **Statut** | **Accepté** |
| **Décideurs** | Équipe développement |

---

## Contexte

Notre application Flutter doit gérer l'état de l'interface (réservations, authentification, navigation) de manière prévisible et testable.

---

## Problème

**Choisir une solution de state management adaptée à la complexité de notre application.**

---

## Options Considérées

### Option 1: setState() Simple

<table>
<tr>
<td width="50%">

**Avantages**
- Intégré à Flutter
- Simplicité

</td>
<td width="50%">

**Inconvénients**
- Pas scalable
- Difficile à tester
- Pas de séparation des préoccupations

</td>
</tr>
</table>

---

### Option 2: Provider

<table>
<tr>
<td width="50%">

**Avantages**
- Recommandé par Google
- Simplicité relative

</td>
<td width="50%">

**Inconvénients**
- Pas assez structuré pour logique complexe
- Tests difficiles

</td>
</tr>
</table>

---

### Option 3: BLoC Pattern **[CHOISI]**

<table>
<tr>
<td width="50%">

**Avantages**
- Séparation UI/Business Logic
- Très testable
- Gestion d'état prévisible
- Réactif avec Streams

</td>
<td width="50%">

**Inconvénients**
- Courbe d'apprentissage

</td>
</tr>
</table>

---

## Décision

**BLoC Pattern avec Repository Pattern** est utilisé pour la gestion d'état.

---

## Justification

**Testabilité:** Logique métier séparée de l'UI

**Prévisibilité:** États d'application clairs

**Architecture:** S'aligne avec Clean Architecture

**Réactivité:** Parfait pour temps réel (réservations)
