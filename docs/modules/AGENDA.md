# 📅 Module Agenda — Guide de travail

> Agenda et rappels de soins : vaccination, vermifuge, médicaments, rendez-vous
> vétérinaires, toilettage. Chaque rappel est lié à un animal et appartient à son
> propriétaire.
>
> Références : [ARCHITECTURE](../ARCHITECTURE.md) · [MOBILE](../MOBILE.md) ·
> [API](../API.md) · [DATA_MODEL](../DATA_MODEL.md) · [CONTRIBUTING](../CONTRIBUTING.md)

---

## 1. État actuel du module

### ⚙️ Backend (`com.petcare.agenda`)

| Fichier | Rôle |
|---------|------|
| `domain/AgendaItem.java` | Document MongoDB `agenda_items` : `ownerId`, `petId`, `type`, `title`, `notes`, `scheduledAt`, `reminderAt`, `status`, `recurrence`, `vetName`, `location`, `durationMinutes`, `urgent` + audit |
| `domain/AgendaItemType.java` | `VACCINATION`, `DEWORMING`, `MEDICATION`, `VET_APPOINTMENT`, `GROOMING` |
| `domain/AgendaItemStatus.java` | `SCHEDULED`, `DONE`, `MISSED`, `CANCELLED` |
| `domain/AgendaItemRecurrence.java` | `EVERY_WEEK` … `EVERY_YEAR` + calcul de la prochaine occurrence |
| `dto/AgendaItemRequest.java` · `AgendaItemResponse.java` · `UpdateAgendaStatusRequest.java` | Objets d'échange |
| `repository/AgendaItemRepository.java` | Requêtes dérivées (dont `findByStatusAndScheduledAtBefore`) |
| `repository/AgendaItemRepositoryCustom(Impl).java` | Recherche dynamique `MongoTemplate` (filtres `petId`, `type`, `from`, `to`) |
| `service/AgendaService.java` + `AgendaServiceImpl.java` | CRUD + contrôle de propriété + animal existant + récurrence au passage à `DONE` |
| `controller/AgendaController.java` | Endpoints REST, rôle `PET_OWNER` |
| `config/AgendaSchedulingConfig.java` | Active `@Scheduled` pour le module |
| `scheduler/AgendaReminderScheduler.java` | Toutes les heures : rappels `SCHEDULED` dépassés → `MISSED` |

**Endpoints :**
```
POST   /agenda                                   créer un rappel / rendez-vous
GET    /agenda?petId=&type=&from=&to=            lister (filtres optionnels, dates ISO-8601)
GET    /agenda/{id}                              détail
PUT    /agenda/{id}                              modifier (corps complet)
PATCH  /agenda/{id}/status                       changer le statut (DONE, CANCELLED…)
DELETE /agenda/{id}                              supprimer
```

### 📱 Mobile (`lib/features/agenda/`)

| Fichier | Rôle |
|---------|------|
| `domain/agenda_item.dart` | Entité `AgendaItem` + désérialisation JSON |
| `data/agenda_api.dart` | Appels REST (dio) |
| `data/agenda_notifications.dart` | Notifications locales programmées sur `reminderAt` (Android) |
| `presentation/agenda_controller.dart` | Providers Riverpod (liste, CRUD, statut, notifications) |
| `presentation/agenda_page.dart` | Écran : vues Mois / Semaine / Liste, filtres animal + type, sections, Valider / Annuler |
| `presentation/agenda_form_page.dart` | Formulaire créer / modifier / supprimer (dont choix du rappel) |
| `presentation/agenda_colors.dart` | Palette locale tirée de la maquette Figma |

---

## 2. Check-list

### Backend
- [x] Filtre par période `from`/`to` (et `petId`) sur `GET /agenda` (repository + service + controller).
- [x] Exploiter `reminderAt` : tâche `@Scheduled` (retards → `MISSED`) + notifications locales côté mobile.
- [x] Logique de **récurrence** (`recurrence`) : prochaine occurrence créée au passage à `DONE`.
- [x] Champs d'affichage : `vetName`, `location`, `durationMinutes`, `urgent`.
- [ ] Tests du service — non réalisés (validation manuelle via l'application).

### Mobile (Clean Architecture — voir [MOBILE.md](../MOBILE.md))
- [x] `domain/` : entité `AgendaItem` (structure alignée sur la feature `pets` : pas d'interface repository ni de use cases).
- [x] `data/` : `AgendaApi` (dio) + désérialisation JSON + service de notifications.
- [x] `presentation/` : créer / modifier / supprimer un rappel (formulaire → POST/PUT/DELETE).
- [x] `presentation/` : marquer fait / annulé (PATCH `/status`, avec confirmation pour l'annulation).
- [x] `presentation/` : vues **Mois** (calendrier), **Semaine** et **Liste** + sections Aujourd'hui / À venir / Passés.
- [x] `presentation/` : filtres par animal / type / période.
- [x] **Notifications locales** (`flutter_local_notifications`) basées sur `reminderAt` (Android).

### Reporté
- Carte / itinéraire du rendez-vous (nécessite le SDK Google Maps et une clé API).

### Dépendances (déjà fournies)
- **Auth** → JWT sécurise déjà les endpoints. ✅
- **Pets** → `PetService.exists()` déjà utilisé pour rattacher un rappel à un animal. ✅

---

## 3. Règles de travail

- **Ne jamais toucher / committer / pousser sur `main`.** Travailler sur une branche dédiée :
  ```bash
  git checkout -b feature/agenda
  ```
- **Commits petits et fréquents** : à chaque chose terminée, un commit.
- **Format Conventional Commits**, ex. :
  ```
  feat(agenda): filtre par période sur la liste
  feat(agenda): couche data mobile (api + models + repository)
  test(agenda): tests de propriété du service
  ```
- **Aucune mention d'outil d'IA dans les commits** : pas de « Co-Authored-By », pas de
  « Generated with… », pas de lien de session, pas d'identifiant de modèle. Uniquement la
  description du changement.
- **Valider avant chaque commit** :
  ```bash
  cd backend && mvn -q compile      # + mvn test si backend touché
  cd mobile  && flutter analyze     # + flutter test si pertinent
  ```
- Un module ne touche pas au code d'un autre : passer par les interfaces de service
  (backend) et par les contrats de [API.md](../API.md) (mobile).
- Ouvrir une **Pull Request** vers `main` une fois une tâche cohérente terminée et validée.

## 4. Démarrage rapide

```bash
# 1. Base de données (Docker Desktop lancé)
docker compose up -d

# 2. Backend : lancer PetCareApplication depuis IntelliJ (profil local par défaut)
#   API : http://localhost:8080/api/v1 · Swagger : http://localhost:8080/api/v1/swagger-ui.html

# 3. Mobile (émulateur Android)
flutter emulators --launch petcare_pixel
cd mobile && flutter pub get && flutter run
```
> L'émulateur Android joint le backend via `10.0.2.2` (= `localhost` de la machine hôte),
> déjà configuré dans `lib/core/config/app_config.dart`.

Détails complets dans [SETUP.md](../SETUP.md).