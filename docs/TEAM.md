# 👥 Répartition de l'équipe — Pet-Care (6 personnes)

L'architecture est pensée pour être **découpée en 6 tranches verticales autonomes** :
**1 personne = 1 module = backend + mobile + doc**. Chacun peut avancer en
parallèle grâce au **socle commun** (déjà en place) et aux **contrats d'API**
définis dans [API.md](API.md).

---

## 0. Socle commun — déjà construit (dépendance de tout le monde)

Avant de répartir, tout le monde s'appuie sur ces fondations **déjà en place**.
Elles ne « appartiennent » à personne en particulier : à maintenir par le/la
**lead** ou en revue collective.

| Zone | Emplacement | Rôle |
|------|-------------|------|
| Sécurité JWT + RBAC | `backend/.../common/security/` | Auth, filtre JWT, rôles |
| Gestion d'erreurs | `backend/.../common/exception/` | Réponses d'erreur uniformes |
| DTO génériques | `backend/.../common/dto/` | `ApiResponse`, `PageResponse`, `ErrorResponse` |
| Config (Mongo, OpenAPI, CORS, seed) | `backend/.../common/config/` | Démarrage |
| Core mobile | `mobile/lib/core/` | Réseau (dio+JWT), thème, routing, DI, widgets |
| Infra | `docker-compose.yml`, `pom.xml`, `pubspec.yaml` | Build & run |
| Docs transverses | `ARCHITECTURE.md`, `DATA_MODEL.md`, `SECURITY.md`, `API.md`, `SETUP.md`, `CONTRIBUTING.md` | Référence commune |

> ⚠️ Toute modification du socle impacte les 6 : passer par une PR relue.

---

## 1. Répartition par personne

Chaque personne possède **la tranche complète** de son module : document(s)
MongoDB, repository, service, controller, DTO côté backend **et** la feature
`data/domain/presentation` côté mobile.

| # | Personne | Module | Backend (`com.petcare.…`) | Mobile (`lib/features/…`) |
|---|----------|--------|---------------------------|---------------------------|
| 1 | _(à nommer)_ | **User / Auth** | `user/` | `auth/` |
| 2 | _(à nommer)_ | **Pets** | `pet/` | `pets/` |
| 3 | _(à nommer)_ | **Dossier médical** | `medicalrecord/` | `medical_record/` |
| 4 | _(à nommer)_ | **Marketplace** | `marketplace/` | `marketplace/` |
| 5 | _(à nommer)_ | **Agenda** | `agenda/` | `agenda/` |
| 6 | _(à nommer)_ | **Événements** | `event/` | `events/` |

---

## 2. Détail par module : fait ✅ / à compléter 🔧

### 👤 Personne 1 — User / Auth
- ✅ Signup / login / refresh JWT, gestion des rôles (Admin/PetOwner/Vet), profil.
- ✅ Mobile : écrans login / signup, état d'authentification, gardes de route.
- 🔧 Reset de mot de passe, édition de profil mobile, écran admin de gestion des utilisateurs.
- **Débloque les 5 autres** (tout le monde a besoin de l'auth) → à prioriser.

### 🐶 Personne 2 — Pets
- ✅ CRUD profils animaux + contrôle de propriété ; mobile : liste, détail, ajout.
- 🔧 Upload de photo (stockage fichier), édition/suppression côté mobile, filtres.
- **Dépend de** : User (auth). **Fournit** `PetService.exists()` à : Médical, Agenda, Événements.

### 🩺 Personne 3 — Dossier médical
- ✅ Dossier par animal (consultations, vaccins, allergies, médicaments) ; mobile : consultation en lecture.
- 🔧 **Contrôle d'accès en lecture** (propriétaire/véto/admin — voir note sécurité ci-dessous),
  lien **vétérinaire ↔ animal suivi**, écrans d'ajout côté véto.
- **Dépend de** : User, Pets.

### 🛒 Personne 4 — Marketplace
- ✅ Catalogue produits, panier, commandes (backend complet) ; mobile : catalogue.
- 🔧 Écran **panier** + **passage de commande** mobile (API déjà prête), suivi des commandes, (plus tard) paiement.
- **Dépend de** : User.

### 📅 Personne 5 — Agenda
- ✅ CRUD rappels liés à un animal + contrôle de propriété ; mobile : liste.
- 🔧 Vue calendrier, création/édition mobile, **notifications locales/push**, récurrence.
- **Dépend de** : User, Pets.

### 🎉 Personne 6 — Événements
- ✅ CRUD événements (admin) + inscription/désinscription (backend) ; mobile : liste.
- 🔧 Écran **inscription** mobile (API prête), détail d'événement, gestion admin mobile.
- **Dépend de** : User, Pets.

---

## 3. Travailler en parallèle sans conflit

1. **Contrats d'abord** : chacun respecte les routes/DTO décrits dans [API.md](API.md).
   Tant que le contrat est stable, backend et mobile d'un même module avancent ensemble.
2. **Un module ne touche pas au code d'un autre** : il passe par l'**interface de service**
   (ex. Agenda utilise `PetService`, jamais `PetRepository`). Voir [ARCHITECTURE.md](ARCHITECTURE.md).
3. **Branches & PR** : une branche par tâche (`feature/<module>-<sujet>`), PR relue avant merge
   sur `main`. Conventions dans [CONTRIBUTING.md](CONTRIBUTING.md).
4. **Mock en attendant** : si une dépendance n'est pas prête, mocker la réponse (côté mobile)
   ou stubber le service (côté backend) pour ne pas être bloqué.

## 4. Ordre de démarrage conseillé

```
Semaine 1 : Personne 1 (Auth) livre login/signup/JWT  →  débloque tout le monde
            Personne 2 (Pets) démarre en parallèle (CRUD animaux)
Semaine 2 : Personnes 3, 5, 6 démarrent (dépendent de Pets)
            Personne 4 (Marketplace) avance indépendamment
Semaine 3+ : finalisation des écrans mobiles stub + features 🔧
```

## 5. Rôles transverses à se répartir en plus

- **Lead / intégration** : garde le socle commun, arbitre les PR, maintient `main` verte.
- **DevOps / CI** : met en place la CI (build backend + `flutter analyze`/test), les environnements.
- **QA / tests** : stratégie de tests (voir pistes dans chaque module), tests d'intégration.

*(peuvent être cumulés avec un module)*

---

## 📌 Note sécurité à traiter (Personne 3 + lead)

La lecture du dossier médical (`GET /pets/{petId}/medical-record`) n'applique
pas encore de contrôle de propriété : à restreindre à **propriétaire de l'animal
/ vétérinaire suivant / admin**. Détails et bonnes pratiques dans [SECURITY.md](SECURITY.md).
