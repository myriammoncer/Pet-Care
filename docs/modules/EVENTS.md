# 🎉 Module Événements — Guide de travail

> Événements communautaires autour des animaux : promenades collectives, concours de
> beauté, journées santé, adoption, ateliers. L'admin crée et gère les événements ;
> tout utilisateur connecté s'inscrit **avec un de ses animaux**.
>
> Références : [ARCHITECTURE](../ARCHITECTURE.md) · [MOBILE](../MOBILE.md) ·
> [API](../API.md#module-événements) · [DATA_MODEL](../DATA_MODEL.md#collection-events) · [CONTRIBUTING](../CONTRIBUTING.md)

---

## 1. État du module

### ⚙️ Backend (`com.petcare.event`)

| Fichier | Rôle |
|---------|------|
| `domain/Event.java` | Document `events` : titre, description, type, `startAt`/`endAt`, lieu, capacité, `participants[]` embarqués `{userId, petId, registeredAt}`, `createdBy` + audit. Index `startAt`, `type`, `participants.userId` |
| `domain/EventType.java` | `GROUP_WALK`, `BEAUTY_CONTEST`, `HEALTH_DAY`, `ADOPTION`, `TRAINING_WORKSHOP` |
| `dto/EventRequest.java` | Entrée admin validée (`@NotBlank`, `@Positive`, `endAt` > `startAt` via `@AssertTrue`) |
| `dto/EventResponse.java` | Sortie : + `registeredCount`, `full`, `registered`, `myPetId` (calculés pour l'utilisateur courant) |
| `dto/ParticipantResponse.java` | Participant enrichi (nom, email, nom de l'animal) — vue admin |
| `dto/RegisterRequest.java` | `{ petId }` |
| `repository/EventRepository.java` | `findRegisteredBy(userId)` (mes inscriptions) |
| `repository/EventRepositoryCustom(Impl).java` | Recherche `type/from/to` paginée + ajout/retrait de participant **atomiques** (`MongoTemplate`) |
| `service/EventService(Impl).java` | Règles métier (voir §2) — utilise `PetService` et `UserService`, jamais leurs repositories |
| `controller/EventController.java` | Endpoints REST (lecture/inscription : authentifié ; gestion : `ADMIN`) |
| `config/EventDataSeeder.java` | 5 événements de démo si la collection est vide (`petcare.seed.enabled=true`, profil local) |

**Endpoints :**
```
GET    /events?type=&from=&to=          à venir par défaut, tri startAt asc, paginé
GET    /events/me                       mes inscriptions
GET    /events/{id}                     détail
POST   /events                          créer (ADMIN)
PUT    /events/{id}                     modifier (ADMIN)
DELETE /events/{id}                     supprimer (ADMIN)
POST   /events/{id}/register            s'inscrire  { "petId": "..." }
DELETE /events/{id}/register            se désinscrire
GET    /events/{id}/participants        participants (ADMIN)
DELETE /events/{id}/participants/{uid}  retirer un participant (ADMIN)
```

### 📱 Mobile (`lib/features/events/`)

| Fichier | Rôle |
|---------|------|
| `domain/pet_event.dart` | Entités `PetEvent` (+ `canRegister`, `canUnregister`, `remainingSpots`) et `EventParticipant` |
| `data/events_api.dart` | Appels REST (dio) ; erreurs converties en `Failure` avec le message du backend |
| `presentation/events_controller.dart` | Providers Riverpod (`autoDispose` : rien en cache après déconnexion) + `EventsActions` |
| `presentation/events_page.dart` | Onglets **À venir** (filtres par type, tirer pour rafraîchir) / **Mes inscriptions** (à venir + passés) ; bouton « Créer » pour l'admin |
| `presentation/event_detail_page.dart` | Détail, jauge de places, inscription avec choix de l'animal, désinscription ; admin : modifier, supprimer, liste et retrait des participants |
| `presentation/event_form_page.dart` | Formulaire admin créer / modifier (dates début/fin, capacité ≥ inscrits) |
| `presentation/event_ui.dart` | Libellés, icônes, couleurs par type, formats de date FR, widgets partagés |

Navigation interne au module via `Navigator.push` : **aucune modification du routeur commun**.

---

## 2. Règles métier

| Règle | Où | Erreur |
|-------|----|--------|
| On s'inscrit avec **son** animal (même un admin) | `PetService.getById(petId, userId, false)` | 404 / 403 |
| Une inscription par utilisateur et par événement | service + requête atomique | 409 |
| Capacité respectée, même avec des inscriptions simultanées | `addParticipant` : condition `participants.<capacity-1>` absent | 409 « complet » |
| Plus d'inscription / désinscription après le début | service | 409 |
| Création : début dans le futur | service | 409 |
| `endAt` > `startAt` | `@AssertTrue` sur `EventRequest` | 400 |
| Modification : capacité ≥ nombre d'inscrits | service | 409 |
| Participants nominatifs visibles par l'admin uniquement | `@PreAuthorize("hasRole('ADMIN')")` | 403 |

---

## 3. Tests

- Backend : `EventServiceImplTest` (Mockito, horloge fixe) — inscription OK / animal d'un autre / doublon / complet / commencé / course perdue, désinscription, création passée, capacité, ordre de « mes inscriptions », participant supprimé.
- Mobile : `test/features/events/pet_event_test.dart` — désérialisation et règles d'affichage.

```bash
cd backend && ./mvnw verify
cd mobile && flutter analyze && flutter test
```

## 4. Tester à la main

1. `docker compose up -d`, puis lancer le backend (profil `local` → seed admin + 5 événements).
2. Se connecter en **admin** (`admin@petcare.app` / `Admin123!`) → onglet Événements → « Créer ».
3. Créer un compte **propriétaire**, ajouter un animal, s'inscrire à un événement → il apparaît dans « Mes inscriptions ».
4. Réessayer de s'inscrire : bouton remplacé par « Se désinscrire ». Remplir un événement (capacité 1) avec un autre compte → « Complet ».
5. En admin, ouvrir l'événement → liste des participants, retrait d'un participant.

## 5. Pistes suivantes

- Liste d'attente quand l'événement est complet.
- Rappel (notification locale) la veille de l'événement, sur le modèle du module Agenda.
- Image de couverture (dépend du stockage de fichiers du module Pets).
