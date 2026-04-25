# 📜 Guide des Conventions

Ce document définit les standards de développement pour assurer la qualité, la traçabilité et la maintenabilité du code sur le dépôt.

---

## Protection des branches

### Branche `main` (production)

La branche `main` représente le code stable en production.

**Règles :**

1. **Push direct interdit**
2. **Merge uniquement depuis `develop`* par*
3. **Historique propre** (squash ou rebase recommandé)

👉 Concrètement : personne ne travaille directement avec `main`.

---

### Branche `develop` (intégration)

La branche `develop` est le point central de collaboration.
**Toutes les features passent par elle.**

**Flow officiel :**
➡️ `feature/*` → PR → `develop` → (plus tard) → `main`

---

## Règles appliquées sur `develop`


1. **Pull Request obligatoire**

   * Aucun commit direct
   * Tout passe par PR

2. **Force push bloqué**

   * Impossible de réécrire l’historique

---

## Flux de travail

Voici le flow réel que vous devez suivre (et respecter strictement) :

1. Créer une branche depuis `develop` :

   ```bash
   git checkout develop
   git pull
   git checkout -b feature/ma-feature
   ```

2. Développer et commit proprement

3. Push la branche :

   ```bash
   git push origin feature/ma-feature
   ```

4. Ouvrir une Pull Request :

   * **Base : `develop`**
   * **Compare : ta branche**

5. Review par l’équipe

6. Merge dans `develop` via GitHub


## Convention de Nommage des Branches

Format :

```
type/description-succincte
```

| Type        | Usage                   | Exemple                 |
| :---------- | :---------------------- | :---------------------- |
| `feature/`  | Nouvelle fonctionnalité | `feature/auth-jwt`      |
| `fix/`      | Bug                     | `fix/cors-error`        |
| `docs/`     | Documentation           | `docs/update-readme`    |
| `refactor/` | Refactoring             | `refactor/user-service` |
| `test/`     | Tests                   | `test/auth-unit-tests`  |

---

## Convention de Commits (Conventional Commits)

### Format

```
type(scope): description
```

### Types autorisés

* `feat` → nouvelle feature
* `fix` → correction bug
* `docs` → documentation
* `style` → formatage
* `refactor` → refacto
* `perf` → performance
* `chore` → tâches techniques

### Exemples

* `feat(api): add login endpoint`
* `fix(ui): navbar overflow on mobile`
* `refactor(auth): simplify middleware logic`

---


