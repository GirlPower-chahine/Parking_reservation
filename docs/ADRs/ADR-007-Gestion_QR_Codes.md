# ADR-007: Gestion QR Codes

---

## Informations Générales

| **Attribut** | **Valeur** |
|--------------|------------|
| **Date** | 2025-01-27 |
| **Statut** | **Accepté** |
| **Décideurs** | Équipe développement |

---

## Contexte

Chaque place de parking (60 places A01-F10) doit avoir un QR code pour permettre le check-in. Le système doit gérer la génération, validation, et libération automatique des places.

---

## Problème

**Choisir entre génération interne ou service externe pour les QR codes.**

---

## Options Considérées

### Option 1: Génération Interne

<table>
<tr>
<td width="50%">

**Avantages**
- Pas de dépendance externe
- Contrôle total

</td>
<td width="50%">

**Inconvénients**
- Code métier pollué
- Maintenance supplémentaire
- Pas notre cœur de métier

</td>
</tr>
</table>

---

### Option 2: Service Externe **[CHOISI]**

<table>
<tr>
<td width="50%">

**Avantages**
- Séparation des responsabilités
- Service spécialisé plus fiable
- Pas de maintenance QR code
- Changement de provider facile

</td>
<td width="50%">

**Inconvénients**
- Dépendance externe
- Coût potentiel

</td>
</tr>
</table>

---

## Décision

**Service externe** est utilisé pour la génération QR codes.

---

## Justification

**Focus métier:** Concentration sur la logique de réservation

**Fiabilité:** Service spécialisé plus robuste

**Architecture:** Respecte la séparation des préoccupations

**Évolution:** Changement de provider sans impact métier
