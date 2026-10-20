# 🧩 Modules — Pet-Care

Détail fonctionnel et technique de chaque module métier. Chaque module suit la
même structure interne (`domain / repository / service / controller / dto`)
décrite dans [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 1. Module `user`

**Responsabilité** — Authentification, inscription, gestion des comptes et des rôles.

### Fonctionnalités
- Inscription (signup) d'un propriétaire ou d'un vétérinaire.
- Authentification (login) → délivrance de tokens JWT (access + refresh).
- Rafraîchissement du token (refresh).
- Consultation / mise à jour du profil.
- Gestion des rôles par l'administrateur (`GetAdmin`, attribution de rôle).
- Activation / désactivation d'un compte.

### Rôles (`Role`)
| Rôle | Description |
|------|-------------|
| `ADMIN` | Supervise la plateforme, gère les utilisateurs et le catalogue. |
| `PET_OWNER` | Propriétaire d'un ou plusieurs animaux. |
| `VET` | Vétérinaire, accède aux dossiers médicaux des animaux suivis. |

### Entités principales
- `User` (collection `users`) : email, mot de passe (haché BCrypt), nom, rôles, statut, téléphone.

### Endpoints clés
`POST /auth/signup` · `POST /auth/login` · `POST /auth/refresh` · `GET /users/me` ·
`GET /users` (admin) · `PATCH /users/{id}/roles` (admin). Voir [API.md](API.md#module-user).

---

## 2. Module `pet`

**Responsabilité** — Création et gestion des profils des animaux.

### Fonctionnalités
- Création, consultation, mise à jour et suppression d'un profil animal.
- Liste des animaux d'un propriétaire.
- Upload / mise à jour de la photo (URL).
- Gestion du statut de l'animal.

### Informations gérées
Nom, race (`breed`), espèce (`species`), âge / date de naissance, sexe (`sex`),
poids (`weight`), couleur (`color`), photo (`photoUrl`), **numéro de puce
électronique** (`microchipNumber`), statut (`status`).

### Enums
- `Species` : `DOG`, `CAT`, `BIRD`, `RABBIT`, `RODENT`, `REPTILE`, `OTHER`.
- `Sex` : `MALE`, `FEMALE`, `UNKNOWN`.
- `PetStatus` : `HEALTHY`, `UNDER_TREATMENT`, `LOST`, `DECEASED`, `FOR_ADOPTION`.

### Entités principales
- `Pet` (collection `pets`) : référence `ownerId` (→ `users`).

### Endpoints clés
`POST /pets` · `GET /pets` · `GET /pets/{id}` · `PUT /pets/{id}` · `DELETE /pets/{id}`.
Voir [API.md](API.md#module-pets).

---

## 3. Module `medicalrecord`

**Responsabilité** — Centralisation des informations médicales de chaque animal.

### Fonctionnalités
- Un **dossier médical** par animal, enrichi par le vétérinaire.
- **Historique médical** : consultations et soins (date, motif, diagnostic, notes, vétérinaire).
- **Vaccinations** : type de vaccin, date, rappel prévu, vétérinaire.
- **Allergies** : substance, sévérité, réaction, notes.
- **Médicaments** : nom, dosage, fréquence, dates de début / fin, prescripteur.

### Entités principales
- `MedicalRecord` (collection `medical_records`) : référence `petId`, contient des
  sous-documents embarqués : `consultations[]`, `vaccinations[]`, `allergies[]`, `medications[]`.

> **Choix de modélisation** : les sous-éléments sont **embarqués** dans le dossier
> (et non des collections séparées) car ils sont toujours consultés dans le
> contexte de l'animal et leur volume reste borné. Voir [DATA_MODEL.md](DATA_MODEL.md#medical_records).

### Accès
- `VET` : lecture/écriture sur les animaux qu'il suit.
- `PET_OWNER` : lecture seule sur ses propres animaux.
- `ADMIN` : lecture.

### Endpoints clés
`GET /pets/{petId}/medical-record` · `POST /pets/{petId}/medical-record/consultations` ·
`POST .../vaccinations` · `POST .../allergies` · `POST .../medications`. Voir [API.md](API.md#module-dossier-médical).

---

## 4. Module `marketplace`

**Responsabilité** — Boutique en ligne de produits pour animaux.

### Fonctionnalités
- Catalogue de **produits** classés par catégorie.
- **Panier** (ajout, modification de quantité, suppression).
- **Commandes** : passage de commande depuis le panier, suivi du statut.
- Gestion du catalogue par l'administrateur.

### Catégories (`ProductCategory`)
`FOOD` (nourriture), `ACCESSORIES` (accessoires), `TOYS` (jouets), `HYGIENE` (hygiène).

### Statuts de commande (`OrderStatus`)
`PENDING`, `CONFIRMED`, `SHIPPED`, `DELIVERED`, `CANCELLED`.

### Entités principales
- `Product` (collection `products`) : nom, description, catégorie, prix, stock, photo.
- `Cart` (collection `carts`) : un panier par utilisateur, lignes `items[]`.
- `Order` (collection `orders`) : lignes figées, montant total, statut, adresse.

### Endpoints clés
`GET /products` · `GET /products/{id}` · `POST /products` (admin) ·
`GET /cart` · `POST /cart/items` · `POST /orders` · `GET /orders`. Voir [API.md](API.md#module-marketplace).

---

## 5. Module `agenda`

**Responsabilité** — Planification et rappels des soins.

### Fonctionnalités
- Création d'éléments d'agenda liés à un animal.
- Rappels (notifications) avant l'échéance.
- Marquage « effectué », récurrence (ex. vermifuge tous les 3 mois).
- Vue calendrier / liste à venir.

### Types (`AgendaItemType`)
`VACCINATION`, `DEWORMING` (vermifuge), `MEDICATION`, `VET_APPOINTMENT` (rendez-vous), `GROOMING` (toilettage).

### Statuts (`AgendaItemStatus`)
`SCHEDULED`, `DONE`, `MISSED`, `CANCELLED`.

### Entités principales
- `AgendaItem` (collection `agenda_items`) : référence `petId` et `ownerId`, date
  prévue, type, statut, récurrence, rappel.

### Endpoints clés
`POST /agenda` · `GET /agenda` (filtres : pet, type, période) · `PATCH /agenda/{id}/status` ·
`DELETE /agenda/{id}`. Voir [API.md](API.md#module-agenda).

---

## 6. Module `event`

**Responsabilité** — Événements et activités dédiés aux animaux.

### Fonctionnalités
- Consultation du catalogue d'événements à venir.
- Inscription / désinscription d'un participant (avec son animal).
- Création et gestion des événements par l'administrateur.
- Gestion de la capacité (nombre de places).

### Types (`EventType`)
`GROUP_WALK` (promenade collective), `BEAUTY_CONTEST` (concours de beauté),
`HEALTH_DAY` (journée santé), `ADOPTION` (adoption), `TRAINING_WORKSHOP` (atelier / dressage).

### Entités principales
- `Event` (collection `events`) : titre, description, type, date, lieu, capacité,
  liste des participants (`participants[]`).

### Endpoints clés
`GET /events` · `GET /events/{id}` · `POST /events` (admin) · `POST /events/{id}/register` ·
`DELETE /events/{id}/register`. Voir [API.md](API.md#module-événements).

---

## Matrice modules × rôles

| Module | ADMIN | PET_OWNER | VET |
|--------|:-----:|:---------:|:---:|
| user (gestion comptes/rôles) | ✅ CRUD | 🔸 son profil | 🔸 son profil |
| pet | ✅ lecture | ✅ ses animaux | 🔸 animaux suivis (lecture) |
| medicalrecord | 🔸 lecture | 🔸 ses animaux (lecture) | ✅ écriture animaux suivis |
| marketplace (catalogue) | ✅ CRUD | 🔸 lecture | 🔸 lecture |
| marketplace (panier/commande) | 🔸 | ✅ | ✅ |
| agenda | 🔸 lecture | ✅ ses animaux | 🔸 animaux suivis |
| event (gestion) | ✅ CRUD | 🔸 inscription | 🔸 inscription |

✅ accès complet · 🔸 accès partiel / restreint
