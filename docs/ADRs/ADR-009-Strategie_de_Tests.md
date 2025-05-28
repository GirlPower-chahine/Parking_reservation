# ADR-009: Stratégie de Tests

---

## Informations Générales

| **Attribut** | **Valeur** |
|--------------|------------|
| **Date** | 2025-01-27 |
| **Statut** | **Accepté** |
| **Décideurs** | Équipe développement |

---

## Contexte

Le projet exige des "tests qui signifient quelque chose" pour garantir la qualité et éviter les régressions.

---

## Problème

**Définir une stratégie de tests complète et efficace.**

---

## Options Considérées

### Option 1: Tests Unitaires Uniquement

<table>
<tr>
<td width="50%">

**Avantages**
-

</td>
<td width="50%">

**Inconvénients**
- Pas de test d'intégration
- Bugs en production possibles

</td>
</tr>
</table>

---

### Option 2: Tests Complets (Pyramide de Tests) **[CHOISI]**

<table>
<tr>
<td width="50%">

**Avantages**
- Détection précoce des bugs
- Confiance dans les déploiements
- Documentation vivante

</td>
<td width="50%">

**Inconvénients**
-

</td>
</tr>
</table>

---

## Décision

**Stratégie de tests pyramidale complète** est implémentée.

### Backend
- Tests unitaires (JUnit 5 + Mockito)
- Tests d'intégration (TestContainers)
- Tests API (MockMvc)

### Frontend
- Tests unitaires (flutter_test)
- Tests widgets
- Tests d'intégration end-to-end

---

## Justification

**Qualité:** Détection précoce des régressions

**Confiance:** Déploiements sécurisés

**Documentation:** Tests comme spécifications

**TestContainers:** Tests avec vraie base de données

---

*Document validé par l'équipe développement le 2025-01-27*
