# 📱 Application mobile (Flutter) — Pet-Care

Architecture, organisation du code et conventions de l'application Flutter.

---

## 1. Principes

L'app suit une **Clean Architecture feature-first** : le code est d'abord
regroupé par fonctionnalité, et chaque fonctionnalité est découpée en trois
couches indépendantes.

```
lib/
├── main.dart                 # Point d'entrée, bootstrap (DI, thème, router)
├── core/                     # Code transverse réutilisable
│   ├── config/               # Constantes, env (baseUrl), flavors
│   ├── network/              # Client dio, intercepteurs (JWT, erreurs, logs)
│   ├── theme/                # Couleurs, typographies, ThemeData clair/sombre
│   ├── router/               # go_router + gardes de route par rôle
│   ├── di/                   # Injection de dépendances (providers Riverpod / get_it)
│   ├── error/                # Failures, exceptions, mapping d'erreurs
│   ├── utils/                # Helpers (formatters, validators)
│   └── widgets/              # Composants UI partagés (boutons, loaders…)
│
└── features/<feature>/
    ├── data/
    │   ├── datasources/      # Appels API (remote) + cache local éventuel
    │   ├── models/           # DTO JSON (fromJson/toJson) ↔ API
    │   └── repositories/     # Implémentation des repositories du domaine
    ├── domain/
    │   ├── entities/         # Objets métier purs (sans dépendance Flutter)
    │   ├── repositories/     # Interfaces (contrats)
    │   └── usecases/         # Cas d'usage (une action = une classe)
    └── presentation/
        ├── providers/        # État (Riverpod : Notifier / AsyncNotifier)
        ├── pages/            # Écrans
        └── widgets/          # Composants spécifiques à la feature
```

Features : `auth`, `pets`, `medical_record`, `marketplace`, `agenda`, `events`.

## 2. Règle de dépendance

```
presentation ──▶ domain ◀── data
```

- `presentation` dépend de `domain` (use cases, entities).
- `data` implémente les interfaces de `domain`.
- `domain` ne dépend de **rien** (ni Flutter, ni dio) → 100 % testable.

## 3. State management — Riverpod

- Un **provider** par morceau d'état (ex. `petsListProvider`).
- Les appels asynchrones utilisent `AsyncNotifier` / `FutureProvider` →
  l'UI réagit aux états `loading / data / error` via `AsyncValue`.
- Les use cases sont injectés dans les providers.

```dart
final petsListProvider =
    AsyncNotifierProvider<PetsListNotifier, List<Pet>>(PetsListNotifier.new);

class PetsListNotifier extends AsyncNotifier<List<Pet>> {
  @override
  Future<List<Pet>> build() => ref.read(getPetsUseCaseProvider)();
}
```

## 4. Réseau

- **dio** centralise les appels HTTP (`core/network/api_client.dart`).
- Un **intercepteur** ajoute automatiquement `Authorization: Bearer <token>`.
- Un **intercepteur** gère le `401` → tentative de refresh → rejoue la requête.
- Les erreurs réseau sont converties en `Failure` typées (`core/error`).

## 5. Navigation

- **go_router** définit les routes de façon déclarative (`core/router`).
- Des **redirections** protègent les routes selon l'authentification et le rôle
  (ex. une page admin redirige un `PET_OWNER` vers l'accueil).

```
/            → écran d'accueil (selon rôle)
/login       → connexion
/signup      → inscription
/pets        → liste des animaux        /pets/:id        → détail
/pets/:id/medical → dossier médical
/marketplace → catalogue                /cart  /orders
/agenda      → agenda / rappels
/events      → événements                /events/:id
/profile     → profil
/admin/...   → espace admin (rôle ADMIN requis)
```

## 6. Thème & UI

- `ThemeData` clair **et** sombre (`core/theme`).
- Palette, typographie et espacements centralisés (design tokens).
- Composants réutilisables dans `core/widgets` (boutons, champs, états vides, loaders).

## 7. Stockage local

- **flutter_secure_storage** pour les tokens JWT (Keychain / Keystore).
- Cache léger optionnel (ex. dernier catalogue) via `shared_preferences`.

## 8. Dépendances principales (voir `mobile/pubspec.yaml`)

| Paquet | Rôle |
|--------|------|
| `flutter_riverpod` | Gestion d'état. |
| `go_router` | Navigation déclarative. |
| `dio` | Client HTTP. |
| `flutter_secure_storage` | Stockage sécurisé des tokens. |
| `freezed` / `json_serializable` | Modèles immuables + (dé)sérialisation JSON. |
| `get_it` | Localisateur de services (DI optionnel). |
| `intl` | Formatage des dates / i18n. |

## 9. Tests

- **Unitaires** : use cases et repositories (mock des datasources).
- **Widget** : écrans clés (états loading/error/data).
- Dossier `mobile/test/` miroir de `lib/`.

## 10. Build & flavors

- Flavors `dev` / `prod` (baseUrl différente) via `core/config`.
- `flutter run --flavor dev` / `flutter build apk --flavor prod`.
