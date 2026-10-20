# 🗄️ Modèle de données — MongoDB

Pet-Care utilise **MongoDB**, une base orientée documents. Ce document décrit les
**collections**, leurs **schémas**, les **relations** (par référence ou par
embarquement) et les **index** recommandés.

---

## Conventions

- Clés primaires : `_id` de type `ObjectId` (exposé en `String` dans l'API).
- Relations « un-vers-un faible » et listes bornées → **documents embarqués**.
- Relations « un-vers-plusieurs » volumineuses ou partagées → **référence** (`xxxId`).
- Dates au format ISO-8601 (UTC).
- Toutes les collections portent `createdAt` / `updatedAt` (audit).

## Schéma relationnel (vue logique)

```
users ──1────────∞── pets ──1───────1── medical_records
  │                   │                    (consultations[], vaccinations[],
  │                   │                     allergies[], medications[] embarqués)
  │                   └───1──────∞── agenda_items
  │
  ├──1──────1── carts ──(items[]→ products)
  ├──1──────∞── orders ──(items figés)
  └──∞──────∞── events (participants[])

products (catalogue indépendant)
```

---

## Collection `users`

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant. |
| `email` | String | Unique, sert d'identifiant de connexion. |
| `password` | String | Haché BCrypt (jamais renvoyé par l'API). |
| `firstName` / `lastName` | String | Identité. |
| `phone` | String | Téléphone (optionnel). |
| `roles` | String[] | Sous-ensemble de `{ADMIN, PET_OWNER, VET}`. |
| `enabled` | boolean | Compte actif ou désactivé. |
| `createdAt` / `updatedAt` | Date | Audit. |

```json
{
  "_id": "6650a1f2c3d4e5f6a7b8c9d0",
  "email": "alice@example.com",
  "password": "$2a$10$...",
  "firstName": "Alice",
  "lastName": "Martin",
  "phone": "+33612345678",
  "roles": ["PET_OWNER"],
  "enabled": true,
  "createdAt": "2026-01-10T09:00:00Z",
  "updatedAt": "2026-01-10T09:00:00Z"
}
```

**Index** : `email` (unique).

---

## Collection `pets`

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant. |
| `ownerId` | String (ref → users) | Propriétaire. |
| `name` | String | Nom de l'animal. |
| `species` | enum | `DOG, CAT, BIRD, RABBIT, RODENT, REPTILE, OTHER`. |
| `breed` | String | Race. |
| `birthDate` | Date | Date de naissance (l'âge est calculé). |
| `sex` | enum | `MALE, FEMALE, UNKNOWN`. |
| `weight` | double | Poids (kg). |
| `color` | String | Couleur / robe. |
| `photoUrl` | String | URL de la photo. |
| `microchipNumber` | String | Numéro de puce électronique (unique si présent). |
| `status` | enum | `HEALTHY, UNDER_TREATMENT, LOST, DECEASED, FOR_ADOPTION`. |
| `createdAt` / `updatedAt` | Date | Audit. |

```json
{
  "_id": "6651b2...",
  "ownerId": "6650a1f2c3d4e5f6a7b8c9d0",
  "name": "Rex",
  "species": "DOG",
  "breed": "Labrador",
  "birthDate": "2022-05-01T00:00:00Z",
  "sex": "MALE",
  "weight": 28.5,
  "color": "Sable",
  "photoUrl": "https://cdn.petcare.app/pets/rex.jpg",
  "microchipNumber": "250269604985215",
  "status": "HEALTHY"
}
```

**Index** : `ownerId`, `microchipNumber` (unique, sparse).

---

## Collection `medical_records`

Un dossier par animal. Les sous-éléments sont **embarqués**.

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant. |
| `petId` | String (ref → pets) | Animal concerné (unique). |
| `consultations` | Consultation[] | Historique médical. |
| `vaccinations` | Vaccination[] | Vaccins administrés. |
| `allergies` | Allergy[] | Allergies connues. |
| `medications` | Medication[] | Traitements médicamenteux. |
| `createdAt` / `updatedAt` | Date | Audit. |

Sous-documents :

```
Consultation : { id, date, reason, diagnosis, notes, vetId }
Vaccination  : { id, vaccineName, date, nextDueDate, vetId }
Allergy      : { id, substance, severity(LOW|MEDIUM|HIGH), reaction, notes }
Medication   : { id, name, dosage, frequency, startDate, endDate, prescribedBy }
```

```json
{
  "_id": "6652c3...",
  "petId": "6651b2...",
  "consultations": [
    { "id": "c1", "date": "2026-02-01T10:00:00Z", "reason": "Boiterie",
      "diagnosis": "Entorse légère", "notes": "Repos 1 semaine", "vetId": "6650ff..." }
  ],
  "vaccinations": [
    { "id": "v1", "vaccineName": "Rage", "date": "2026-01-15T00:00:00Z",
      "nextDueDate": "2027-01-15T00:00:00Z", "vetId": "6650ff..." }
  ],
  "allergies": [
    { "id": "a1", "substance": "Poulet", "severity": "MEDIUM",
      "reaction": "Démangeaisons", "notes": "" }
  ],
  "medications": [
    { "id": "m1", "name": "Anti-inflammatoire", "dosage": "10mg",
      "frequency": "1x/jour", "startDate": "2026-02-01T00:00:00Z",
      "endDate": "2026-02-08T00:00:00Z", "prescribedBy": "6650ff..." }
  ]
}
```

**Index** : `petId` (unique).

---

## Collection `products`

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant. |
| `name` | String | Nom du produit. |
| `description` | String | Description. |
| `category` | enum | `FOOD, ACCESSORIES, TOYS, HYGIENE`. |
| `price` | double | Prix unitaire. |
| `currency` | String | Devise (ex. `EUR`). |
| `stock` | int | Quantité disponible. |
| `photoUrl` | String | Illustration. |
| `active` | boolean | Visible au catalogue. |

**Index** : `category`, `name` (texte pour la recherche).

---

## Collection `carts`

Un panier par utilisateur.

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant. |
| `userId` | String (ref → users) | Propriétaire du panier (unique). |
| `items` | CartItem[] | `{ productId, quantity }`. |
| `updatedAt` | Date | Dernière modification. |

**Index** : `userId` (unique).

---

## Collection `orders`

Les lignes de commande **figent** le prix et le nom au moment de l'achat
(indépendance vis-à-vis des évolutions du catalogue).

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant. |
| `userId` | String (ref → users) | Client. |
| `items` | OrderItem[] | `{ productId, productName, unitPrice, quantity }`. |
| `totalAmount` | double | Montant total. |
| `currency` | String | Devise. |
| `status` | enum | `PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED`. |
| `shippingAddress` | Address | Adresse de livraison embarquée. |
| `createdAt` / `updatedAt` | Date | Audit / suivi. |

**Index** : `userId`, `status`, `createdAt`.

---

## Collection `agenda_items`

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant. |
| `petId` | String (ref → pets) | Animal concerné. |
| `ownerId` | String (ref → users) | Propriétaire (pour filtrage rapide). |
| `type` | enum | `VACCINATION, DEWORMING, MEDICATION, VET_APPOINTMENT, GROOMING`. |
| `title` | String | Libellé. |
| `notes` | String | Détails. |
| `scheduledAt` | Date | Date/heure prévue. |
| `reminderAt` | Date | Date/heure du rappel (notification). |
| `status` | enum | `SCHEDULED, DONE, MISSED, CANCELLED`. |
| `recurrence` | String | Règle de récurrence (ex. `EVERY_3_MONTHS`), optionnel. |
| `createdAt` / `updatedAt` | Date | Audit. |

**Index** : `ownerId`, `petId`, `scheduledAt`, `status`.

---

## Collection `events`

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant. |
| `title` | String | Titre de l'événement. |
| `description` | String | Description. |
| `type` | enum | `GROUP_WALK, BEAUTY_CONTEST, HEALTH_DAY, ADOPTION, TRAINING_WORKSHOP`. |
| `startAt` / `endAt` | Date | Début / fin. |
| `location` | String | Lieu. |
| `capacity` | int | Nombre de places. |
| `participants` | Participant[] | `{ userId, petId, registeredAt }`. |
| `createdBy` | String (ref → users) | Admin organisateur. |
| `createdAt` / `updatedAt` | Date | Audit. |

**Index** : `startAt`, `type`, `participants.userId`.

---

## Résumé des relations

| Relation | Type | Implémentation |
|----------|------|----------------|
| User → Pets | 1–∞ | référence `pets.ownerId` |
| Pet → MedicalRecord | 1–1 | référence `medical_records.petId` (unique) |
| MedicalRecord → consultations/vaccins/allergies/médicaments | 1–∞ bornée | **embarqué** |
| User → Cart | 1–1 | référence `carts.userId` (unique) |
| User → Orders | 1–∞ | référence `orders.userId` |
| Pet → AgendaItems | 1–∞ | référence `agenda_items.petId` |
| Event ↔ Users | ∞–∞ | embarqué `events.participants[]` |
