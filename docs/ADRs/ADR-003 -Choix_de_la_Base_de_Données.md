# ADR-003: Choix de la Base de Données

---

## Informations Générales

| **Attribut** | **Valeur** |
|--------------|------------|
| **Date** | 2025-01-27 |
| **Statut** | **Accepté** |
| **Décideurs** | Équipe développement |

---

## Contexte

Notre système doit stocker des utilisateurs, réservations, places de parking, historique, et données analytics. Nous avons besoin de garantir la cohérence des données (pas de double réservation) et supporter des requêtes complexes pour les dashboards.

---

## Problème

**Choisir une base de données adaptée aux besoins de cohérence, performance, et facilité de maintenance.**

---

## Options Considérées

### Option 1: H2 Database

<table>
<tr>
<td width="50%">

**Avantages**
- Parfaite pour développement et tests
- Configuration zéro
- Interface web intégrée

</td>
<td width="50%">

**Inconvénients**
- Pas adaptée à la production
- Données perdues au redémarrage
- Performance limitée

</td>
</tr>
</table>

---

### Option 2: PostgreSQL

<table>
<tr>
<td width="50%">

**Avantages**
- Fonctionnalités avancées (JSON, arrays)
- Performance éprouvée
- Open source

</td>
<td width="50%">

**Inconvénients**
- Complexité configuration
- Moins de ressources Spring Boot
- Pas d'expertise équipe

</td>
</tr>
</table>

---

### Option 3: MySQL **[CHOISI]**

<table>
<tr>
<td width="50%">

**Avantages**
- Mature et stable
- Excellent support Spring Boot
- Expertise équipe IT existante
- Optimisé pour applications web
- Transactions ACID fiables

</td>
<td width="50%">

**Inconvénients**
- Moins de fonctionnalités que PostgreSQL

</td>
</tr>
</table>

---

## Décision

**MySQL 8.0** pour la production et **H2** pour les tests.

---

## Justification

### Fiabilité
Transactions ACID **critiques** pour éviter double réservations

### Expertise
Équipe IT **maîtrise déjà** MySQL

### Performance
**Optimisé** pour nos requêtes analytics

### Écosystème
Intégration Spring Boot **excellente**
