# 🔌 API REST — Pet-Care

Référence des endpoints de l'API backend.

- **Base URL** : `http://localhost:8080/api/v1`
- **Format** : JSON (`Content-Type: application/json`)
- **Authentification** : `Authorization: Bearer <accessToken>` (sauf `/auth/*` publics)
- **Documentation interactive** : Swagger UI sur `http://localhost:8080/swagger-ui.html`

## Enveloppe de réponse

Toutes les réponses suivent une enveloppe uniforme :

```json
{ "success": true, "data": { ... }, "message": null }
```

En cas d'erreur (voir [SECURITY.md](SECURITY.md) et la gestion globale) :

```json
{
  "success": false,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Pet not found: 6651b2",
    "timestamp": "2026-10-20T12:00:00Z",
    "path": "/api/v1/pets/6651b2"
  }
}
```

## Codes HTTP utilisés

| Code | Signification |
|------|---------------|
| 200 | OK |
| 201 | Créé |
| 204 | Pas de contenu (suppression) |
| 400 | Requête invalide (validation) |
| 401 | Non authentifié (token manquant/invalide) |
| 403 | Interdit (rôle insuffisant) |
| 404 | Ressource introuvable |
| 409 | Conflit (ex. email déjà utilisé) |

---

## Module `user`

| Méthode | Route | Rôle | Description |
|---------|-------|------|-------------|
| POST | `/auth/signup` | public | Inscription (PET_OWNER ou VET). |
| POST | `/auth/login` | public | Connexion → tokens JWT. |
| POST | `/auth/refresh` | public | Renouvelle l'access token. |
| GET | `/users/me` | authentifié | Profil courant. |
| PUT | `/users/me` | authentifié | Mise à jour du profil. |
| GET | `/users` | ADMIN | Liste paginée des utilisateurs. |
| GET | `/users/{id}` | ADMIN | Détail d'un utilisateur. |
| PATCH | `/users/{id}/roles` | ADMIN | Modifier les rôles. |
| PATCH | `/users/{id}/status` | ADMIN | Activer / désactiver. |

**Exemple — login**

```http
POST /api/v1/auth/login
{ "email": "alice@example.com", "password": "Secret123!" }
```
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOi...",
    "refreshToken": "eyJhbGciOi...",
    "tokenType": "Bearer",
    "user": { "id": "6650a1", "email": "alice@example.com",
              "firstName": "Alice", "roles": ["PET_OWNER"] }
  }
}
```

---

## Module `pets`

| Méthode | Route | Rôle | Description |
|---------|-------|------|-------------|
| POST | `/pets` | PET_OWNER | Créer un profil animal. |
| GET | `/pets` | PET_OWNER / ADMIN | Liste des animaux (du propriétaire, ou tous pour admin). |
| GET | `/pets/{id}` | propriétaire / VET suivant / ADMIN | Détail. |
| PUT | `/pets/{id}` | propriétaire | Mise à jour. |
| DELETE | `/pets/{id}` | propriétaire / ADMIN | Suppression. |

**Exemple — création**

```http
POST /api/v1/pets
Authorization: Bearer <token>
{
  "name": "Rex", "species": "DOG", "breed": "Labrador",
  "birthDate": "2022-05-01", "sex": "MALE", "weight": 28.5,
  "color": "Sable", "microchipNumber": "250269604985215", "status": "HEALTHY"
}
```

---

## Module `dossier médical`

| Méthode | Route | Rôle | Description |
|---------|-------|------|-------------|
| GET | `/pets/{petId}/medical-record` | propriétaire / VET / ADMIN | Dossier complet. |
| POST | `/pets/{petId}/medical-record/consultations` | VET | Ajouter une consultation. |
| POST | `/pets/{petId}/medical-record/vaccinations` | VET | Ajouter une vaccination. |
| POST | `/pets/{petId}/medical-record/allergies` | VET | Ajouter une allergie. |
| POST | `/pets/{petId}/medical-record/medications` | VET | Ajouter un médicament. |
| DELETE | `/pets/{petId}/medical-record/{section}/{itemId}` | VET | Retirer un élément. |

---

## Module `marketplace`

| Méthode | Route | Rôle | Description |
|---------|-------|------|-------------|
| GET | `/products` | authentifié | Catalogue (filtres : `category`, `q`, pagination). |
| GET | `/products/{id}` | authentifié | Détail produit. |
| POST | `/products` | ADMIN | Créer un produit. |
| PUT | `/products/{id}` | ADMIN | Modifier. |
| DELETE | `/products/{id}` | ADMIN | Supprimer. |
| GET | `/cart` | authentifié | Panier courant. |
| POST | `/cart/items` | authentifié | Ajouter / mettre à jour une ligne. |
| DELETE | `/cart/items/{productId}` | authentifié | Retirer une ligne. |
| POST | `/orders` | authentifié | Valider le panier → commande. |
| GET | `/orders` | authentifié | Mes commandes. |
| GET | `/orders/{id}` | propriétaire / ADMIN | Détail commande. |
| PATCH | `/orders/{id}/status` | ADMIN | Mettre à jour le statut. |

---

## Module `agenda`

| Méthode | Route | Rôle | Description |
|---------|-------|------|-------------|
| POST | `/agenda` | PET_OWNER | Créer un rappel / rendez-vous. |
| GET | `/agenda` | PET_OWNER | Liste (filtres : `petId`, `type`, `from`, `to`). |
| GET | `/agenda/{id}` | propriétaire | Détail. |
| PATCH | `/agenda/{id}/status` | propriétaire | Marquer DONE / CANCELLED. |
| PUT | `/agenda/{id}` | propriétaire | Mise à jour. |
| DELETE | `/agenda/{id}` | propriétaire | Suppression. |

---

## Module `événements`

| Méthode | Route | Rôle | Description |
|---------|-------|------|-------------|
| GET | `/events` | authentifié | Événements à venir (filtres : `type`, `from`, `to`). |
| GET | `/events/{id}` | authentifié | Détail. |
| POST | `/events` | ADMIN | Créer un événement. |
| PUT | `/events/{id}` | ADMIN | Modifier. |
| DELETE | `/events/{id}` | ADMIN | Supprimer. |
| POST | `/events/{id}/register` | authentifié | S'inscrire (avec `petId`). |
| DELETE | `/events/{id}/register` | authentifié | Se désinscrire. |

---

## Pagination

Les listes acceptent `?page=0&size=20&sort=createdAt,desc` et renvoient :

```json
{
  "success": true,
  "data": {
    "content": [ ... ],
    "page": 0, "size": 20, "totalElements": 134, "totalPages": 7
  }
}
```
