# 🤝 Contribuer — Pet-Care

Conventions de développement pour garder une base de code cohérente.

---

## 1. Branches

| Type | Convention | Exemple |
|------|-----------|---------|
| Fonctionnalité | `feature/<module>-<description>` | `feature/pets-crud` |
| Correction | `fix/<description>` | `fix/jwt-refresh-401` |
| Documentation | `docs/<description>` | `docs/api-marketplace` |
| Refactoring | `refactor/<description>` | `refactor/user-service` |

- Branche par défaut : `main` (protégée).
- Pas de push direct sur `main` : passer par une Pull Request.

## 2. Commits — Conventional Commits

Format : `type(scope): description`

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité. |
| `fix` | Correction de bug. |
| `docs` | Documentation. |
| `refactor` | Refactoring sans changement de comportement. |
| `test` | Ajout / modification de tests. |
| `chore` | Maintenance, config, dépendances. |

Exemples :
```
feat(pet): ajout du CRUD des profils animaux
fix(auth): corrige le refresh token expiré
docs(api): documente les endpoints marketplace
```

## 3. Pull Requests

- Titre clair suivant Conventional Commits.
- Description : contexte, ce qui change, comment tester.
- La PR doit compiler et passer les tests (`./mvnw verify`, `flutter test`).
- Au moins une revue avant merge.
- Préférer le **squash merge** pour un historique lisible.

## 4. Style de code

### Backend (Java)
- Java 17, convention de nommage standard (PascalCase classes, camelCase méthodes).
- Un package par module métier (package-by-feature).
- Pas de logique métier dans les controllers.
- DTO systématiques (ne jamais exposer les documents MongoDB).
- Validation (`@Valid`) sur tous les DTO d'entrée.

### Mobile (Dart / Flutter)
- Respecter `flutter analyze` (lints via `flutter_lints`).
- Clean Architecture feature-first (voir [MOBILE.md](MOBILE.md)).
- Widgets `const` quand c'est possible.
- Entities du domaine sans dépendance Flutter.

## 5. Tests

- Toute nouvelle règle métier → test unitaire associé.
- Backend : tests de service (métier) et de controller (API) ;
  utiliser une base Mongo embarquée / Testcontainers.
- Mobile : use cases et providers (mock des datasources).

## 6. Structure attendue d'un nouveau module backend

```
com.petcare.<module>/
├── domain/        # @Document + enums
├── repository/    # interface MongoRepository
├── service/       # interface + impl (logique métier)
├── controller/    # endpoints REST
└── dto/           # requêtes / réponses
```

## 7. Structure attendue d'une nouvelle feature mobile

```
features/<feature>/
├── data/{datasources, models, repositories}
├── domain/{entities, repositories, usecases}
└── presentation/{providers, pages, widgets}
```
