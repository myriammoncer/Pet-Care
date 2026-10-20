# 🏗️ Architecture — Pet-Care

Ce document décrit l'architecture technique globale de la plateforme Pet-Care :
les choix technologiques, la découpe en modules, les flux de données et les
principes de conception.

---

## 1. Vue d'ensemble

Pet-Care suit une architecture **client / serveur** à trois couches :

```
                       ┌──────────────────────────────────────────┐
                       │            CLIENT MOBILE (Flutter)          │
                       │                                            │
                       │   Presentation ──▶ Domain ──▶ Data          │
                       │   (widgets,         (use cases,  (repos,     │
                       │    Riverpod)         entities)    dio/API)   │
                       └───────────────────┬────────────────────────┘
                                           │  REST/JSON over HTTPS
                                           │  Authorization: Bearer <JWT>
                                           ▼
                       ┌──────────────────────────────────────────┐
                       │          BACKEND API (Spring Boot 3)        │
                       │                                            │
                       │  Controller ──▶ Service ──▶ Repository      │
                       │  (REST)          (métier)    (Spring Data)   │
                       │                                            │
                       │  Modules : user · pet · medicalrecord ·     │
                       │            marketplace · agenda · event     │
                       │  Transverse : security (JWT), exception,    │
                       │               config, dto, util             │
                       └───────────────────┬────────────────────────┘
                                           │  MongoDB Driver
                                           ▼
                       ┌──────────────────────────────────────────┐
                       │                 MongoDB                     │
                       │  Collections : users, pets, medical_records,│
                       │  products, orders, carts, agenda_items,     │
                       │  events                                     │
                       └──────────────────────────────────────────┘
```

## 2. Choix technologiques

| Domaine | Technologie | Justification |
|---------|-------------|---------------|
| **Mobile** | Flutter 3.x / Dart 3.x | UI cross-platform (iOS + Android) avec une seule base de code, rendu performant, écosystème riche. |
| **Backend** | Spring Boot 3.x / Java 17 | Framework robuste et typé, architecture modulaire, excellent support de la sécurité et de MongoDB. |
| **Base de données** | MongoDB 7.x | Base documentaire flexible, idéale pour des schémas évolutifs (dossiers médicaux, profils animaux hétérogènes). |
| **Authentification** | JWT (JSON Web Token) | Stateless, adapté au mobile, facilite le scaling horizontal. |
| **Communication** | REST / JSON | Standard, simple à consommer côté mobile, outillage mature. |
| **Conteneurisation** | Docker / Docker Compose | Environnement de dev reproductible (MongoDB), déploiement simplifié. |
| **State management (mobile)** | Riverpod | Gestion d'état réactive, testable et découplée de l'UI. |
| **Navigation (mobile)** | go_router | Routage déclaratif, deep links, gardes de route par rôle. |
| **HTTP client (mobile)** | dio | Intercepteurs (JWT, logs), gestion d'erreurs centralisée. |

## 3. Backend — Monolithe modulaire

Le backend est un **monolithe modulaire** : un seul déployable, mais découpé en
**modules métier autonomes** (package-by-feature). Chaque module est une
« tranche verticale » isolée qui expose une API claire, ce qui prépare une
éventuelle extraction en microservices sans réécriture.

### 3.1 Découpe en packages

```
com.petcare
├── PetCareApplication.java        # Point d'entrée Spring Boot
│
├── common/                        # Code transverse partagé
│   ├── config/                    # Configuration (Mongo, CORS, OpenAPI, Jackson)
│   ├── security/                  # JWT, filtres, UserDetails, RBAC
│   ├── exception/                 # Exceptions + gestion globale (@RestControllerAdvice)
│   ├── dto/                       # DTO génériques (ApiResponse, PageResponse, ErrorResponse)
│   └── util/                      # Utilitaires (dates, mapping…)
│
└── <module>/                      # Un package par module métier
    ├── domain/                    # Documents MongoDB + enums (le cœur métier)
    ├── repository/                # Interfaces Spring Data MongoRepository
    ├── service/                   # Logique métier (interfaces + implémentations)
    ├── controller/                # Endpoints REST (couche d'exposition)
    └── dto/                       # Requêtes / réponses propres au module
```

Modules métier : `user`, `pet`, `medicalrecord`, `marketplace`, `agenda`, `event`.

### 3.2 Couches internes à un module

```
   HTTP Request
        │
        ▼
┌───────────────┐   DTO     ┌───────────────┐  Document  ┌───────────────┐
│  Controller   │ ────────▶ │    Service    │ ─────────▶ │  Repository   │
│  (REST, @Valid)│ ◀──────── │  (règles,     │ ◀───────── │ (Spring Data) │
└───────────────┘           │   transactions)│            └───────┬───────┘
        ▲                   └───────────────┘                    │
        │ ApiResponse<DTO>                                        ▼
   HTTP Response                                            ┌───────────┐
                                                            │  MongoDB  │
                                                            └───────────┘
```

- **Controller** — expose les routes REST, valide les entrées (`@Valid`),
  délègue au service, renvoie des DTO. Aucune logique métier.
- **Service** — contient les règles métier, orchestre les repositories, gère
  les règles d'accès fines. Expose une interface + une implémentation.
- **Repository** — accès aux données via Spring Data MongoDB.
- **Domain** — documents MongoDB annotés `@Document`, cœur du modèle.
- **DTO** — objets d'échange : jamais exposer les documents directement.

### 3.3 Règle de dépendance

Les dépendances pointent **vers l'intérieur** : `controller → service → repository → domain`.
Un module ne doit pas accéder au repository d'un autre module ; il passe par
l'**interface de service** de ce module. Les DTO ne « fuient » jamais vers le
domaine et les documents ne « fuient » jamais vers le controller.

## 4. Mobile — Clean Architecture (feature-first)

L'app Flutter est organisée par **fonctionnalité** (feature-first), chaque
feature étant elle-même découpée en 3 couches (Clean Architecture) :

```
lib/
├── core/            # Transverse : réseau, thème, routing, DI, erreurs, widgets
└── features/<feature>/
    ├── data/        # DataSources (API), models (JSON), implémentations de repo
    ├── domain/      # Entities, interfaces de repository, use cases
    └── presentation/# Pages, widgets, providers Riverpod (état)
```

Flux de données côté mobile :

```
Widget ──▶ Provider (Riverpod) ──▶ UseCase ──▶ Repository(interface)
                                                     │
                                          RepositoryImpl (data)
                                                     │
                                          RemoteDataSource (dio) ──▶ API Backend
```

Détails : **[MOBILE.md](MOBILE.md)**.

## 5. Flux applicatifs clés

### 5.1 Authentification (login)

```
Mobile                         Backend                        MongoDB
  │  POST /api/v1/auth/login     │                               │
  │ ───────────────────────────▶│  charge user par email        │
  │                             │ ─────────────────────────────▶│
  │                             │ ◀───────────────────────────── │
  │                             │  vérifie mot de passe (BCrypt)  │
  │                             │  génère access + refresh JWT    │
  │ ◀─────────────────────────── │                               │
  │  { accessToken, refreshToken, user }                         │
  │  stocke le token (secure storage)                            │
```

### 5.2 Requête authentifiée

```
Mobile ── Authorization: Bearer <JWT> ──▶ JwtAuthFilter
                                              │ valide signature + expiration
                                              │ charge l'utilisateur + rôles
                                              ▼
                                        SecurityContext → @PreAuthorize vérifie le rôle
                                              ▼
                                        Controller → Service → Repository
```

## 6. Principes de conception

1. **Separation of concerns** — chaque couche a une responsabilité unique.
2. **Package-by-feature** — on regroupe par domaine métier, pas par type technique.
3. **DTO systématiques** — les documents MongoDB ne sortent jamais tels quels de l'API.
4. **RBAC** — chaque endpoint est protégé par rôle (`@PreAuthorize`), voir [SECURITY.md](SECURITY.md).
5. **Validation aux frontières** — `@Valid` sur les DTO d'entrée côté backend, validation de formulaire côté mobile.
6. **Gestion d'erreurs centralisée** — `@RestControllerAdvice` renvoie un `ErrorResponse` uniforme.
7. **Stateless** — pas de session serveur ; l'authentification repose sur le JWT.
8. **Testabilité** — logique métier isolée dans les services (backend) et use cases (mobile).

## 7. Environnements

| Environnement | Usage | Base de données |
|---------------|-------|-----------------|
| `local` | Développement sur le poste | MongoDB via Docker Compose |
| `dev` | Intégration partagée | MongoDB managé (ex. Atlas dev) |
| `prod` | Production | MongoDB managé (cluster répliqué) |

La configuration est externalisée via les profils Spring (`application-*.yml`)
et des variables d'environnement pour les secrets (voir [SECURITY.md](SECURITY.md)).

## 8. Évolutivité

- **Horizontale** : l'API étant stateless (JWT), on peut lancer N instances derrière un load balancer.
- **Vers microservices** : la découpe par module permet d'extraire un module (ex. `marketplace`) en service autonome.
- **Stockage fichiers** : les photos (animaux, produits) sont référencées par URL, stockables sur un object storage (S3/GCS) — voir [ROADMAP.md](ROADMAP.md).
