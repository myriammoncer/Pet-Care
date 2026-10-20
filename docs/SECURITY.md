# 🔐 Sécurité — Pet-Care

Authentification, autorisation (RBAC) et bonnes pratiques de sécurité.

---

## 1. Authentification — JWT

L'API est **stateless** : aucune session serveur. Après connexion, le client
reçoit deux jetons :

| Token | Durée de vie | Usage |
|-------|-------------|-------|
| **Access token** | courte (~15 min) | Envoyé à chaque requête dans l'en-tête `Authorization`. |
| **Refresh token** | longue (~7 jours) | Permet d'obtenir un nouvel access token sans se reconnecter. |

### Flux

```
1. POST /auth/login (email, password)
   └─▶ le serveur vérifie le mot de passe (BCrypt), génère access + refresh
2. Le client stocke les tokens dans un stockage sécurisé
   (flutter_secure_storage : Keychain iOS / Keystore Android)
3. Chaque requête protégée : Authorization: Bearer <accessToken>
4. À l'expiration de l'access token (401) :
   └─▶ POST /auth/refresh (refreshToken) → nouvel accessToken
5. Logout : suppression locale des tokens
```

### Contenu du JWT (claims)

```json
{
  "sub": "6650a1f2c3d4e5f6a7b8c9d0",   // userId
  "email": "alice@example.com",
  "roles": ["PET_OWNER"],
  "iat": 1760000000,
  "exp": 1760000900
}
```

Le token est signé avec l'algorithme **HS256** et une clé secrète côté serveur
(`JWT_SECRET`). Le filtre `JwtAuthenticationFilter` valide la signature et
l'expiration à chaque requête, puis alimente le `SecurityContext`.

## 2. Autorisation — RBAC

Trois rôles contrôlent l'accès aux fonctionnalités :

| Rôle | Portée |
|------|--------|
| `ADMIN` | Administration globale de la plateforme. |
| `PET_OWNER` | Ses propres animaux et données associées. |
| `VET` | Dossiers médicaux des animaux qu'il suit. |

### Protection au niveau endpoint

Chaque endpoint est protégé par annotation :

```java
@PreAuthorize("hasRole('ADMIN')")
@PreAuthorize("hasAnyRole('PET_OWNER', 'VET')")
```

### Protection au niveau ressource (ownership)

Au-delà du rôle, le service vérifie que l'utilisateur **possède** la ressource
(ex. un propriétaire ne peut lire que *ses* animaux). Cette vérification se fait
dans la couche service en comparant `ownerId` au `userId` du token.

```java
if (!pet.getOwnerId().equals(currentUserId) && !isAdmin) {
    throw new ForbiddenException("Access denied to pet " + petId);
}
```

## 3. Mots de passe

- Hachés avec **BCrypt** (facteur de coût ≥ 10).
- Jamais stockés ni journalisés en clair.
- Jamais renvoyés par l'API (exclus des DTO de réponse).
- Politique minimale recommandée : ≥ 8 caractères, majuscule + chiffre + symbole
  (validée côté mobile et côté backend).

## 4. Transport & CORS

- **HTTPS** obligatoire en production (TLS).
- **CORS** : seules les origines autorisées (app mobile, éventuel back-office) sont acceptées — configuré dans `CorsConfig`.
- En-têtes de sécurité : `X-Content-Type-Options`, `X-Frame-Options`, HSTS.

## 5. Gestion des secrets

Aucun secret n'est committé. Ils sont fournis par variables d'environnement :

| Variable | Description |
|----------|-------------|
| `JWT_SECRET` | Clé de signature des JWT (≥ 256 bits). |
| `JWT_ACCESS_EXPIRATION` | Durée de vie de l'access token (ms). |
| `JWT_REFRESH_EXPIRATION` | Durée de vie du refresh token (ms). |
| `MONGODB_URI` | URI de connexion MongoDB (avec identifiants). |

Les fichiers `.env`, `application-local.yml`, `application-secrets.yml` sont
ignorés par Git (voir `.gitignore`).

## 6. Validation des entrées

- Backend : `@Valid` + annotations Jakarta (`@NotBlank`, `@Email`, `@Size`, `@Positive`…) sur tous les DTO d'entrée.
- Les documents MongoDB ne sont jamais exposés directement (toujours via DTO) → pas de *mass assignment*.

## 7. Journalisation & audit

- Les champs `createdAt` / `updatedAt` tracent les modifications.
- Les évènements sensibles (login échoué, changement de rôle) sont journalisés sans donnée sensible.
- Ne **jamais** journaliser : mots de passe, tokens, numéros de puce complets en clair.

## 8. Checklist sécurité (résumé)

- [x] Mots de passe hachés (BCrypt)
- [x] JWT signés + expiration courte + refresh
- [x] RBAC par endpoint (`@PreAuthorize`)
- [x] Vérification d'ownership en couche service
- [x] Validation des entrées (`@Valid`)
- [x] Secrets hors du dépôt (variables d'environnement)
- [x] HTTPS + CORS restreint en production
- [x] Pas de document exposé directement (DTO)
