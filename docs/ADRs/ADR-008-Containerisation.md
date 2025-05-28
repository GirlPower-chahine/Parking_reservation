# ADR-008: Containerisation

---

## Informations Générales

| **Attribut** | **Valeur** |
|--------------|------------|
| **Date** | 2025-01-27 |
| **Statut** | **Accepté** |
| **Décideurs** | Équipe développement |

---

## Contexte

Le projet exige une containerisation obligatoire pour faciliter le déploiement et les contributions équipe.

---

## Problème

**Définir la stratégie de containerisation optimale.**

---

## Options Considérées

### Option 1: Containers Séparés **[CHOISI]**

<table>
<tr>
<td colspan="2">

**Composition**
- Spring Boot Container
- MySQL Container
- Nginx Container (pour Flutter Web)

</td>
</tr>
</table>

---

### Option 2: Container Unique

<table>
<tr>
<td width="50%">

**Avantages**
-

</td>
<td width="50%">

**Inconvénients**
- Viole le principe de responsabilité unique
- Debugging complexe

</td>
</tr>
</table>

---

## Décision

**Containers séparés avec Docker Compose** sont utilisés.

---

## Justification

**Isolation:** Chaque service dans son container

**Développement:** Docker Compose pour orchestration locale

**Production:** Déploiement flexible

**Onboarding:** Configuration reproductible
