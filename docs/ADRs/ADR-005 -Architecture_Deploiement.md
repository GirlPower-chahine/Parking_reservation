# ADR-005: Architecture Déploiement

---

## Informations Générales

| **Attribut** | **Valeur** |
|--------------|------------|
| **Date** | 2025-01-27 |
| **Statut** | **Accepté** |
| **Décideurs** | Équipe développement |

---

## Contexte

Notre application doit être déployable facilement, avec une configuration cohérente entre environnements, et faciliter l'onboarding des développeurs.

---

## Problème

**Choisir entre monolithe, microservices, ou une approche hybride.**

---

## Options Considérées

### Option 1: Microservices

<table>
<tr>
<td width="50%">

**Avantages**
- Scalabilité indépendante
- Technologies différentes possibles

</td>
<td width="50%">

**Inconvénients**
- Complexité opérationnelle élevée
- Équipe trop réduite
- Transactions distribuées complexes

</td>
</tr>
</table>

---

### Option 2: Monolithe Modulaire **[CHOISI]**

<table>
<tr>
<td width="50%">

**Avantages**
- Simplicité opérationnelle
- Transactions ACID cross-domain
- Adapté à l'équipe réduite
- Évolution possible vers microservices

</td>
<td width="50%">

**Inconvénients**
- Scalabilité limitée (non critique actuellement)

</td>
</tr>
</table>

---

## Décision

**Architecture monolithe modulaire** est adoptée.

---

## Justification

**Simplicité:** Un seul déploiement pour l'équipe réduite

**Cohérence:** Transactions ACID entre modules

**Évolution:** Possibilité de migration future

**Performance:** Pas de latence réseau inter-services
