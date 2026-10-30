# 📅 Module Agenda — Guide de travail

> Agenda et rappels de soins : vaccination, vermifuge, médicaments, rendez-vous
> vétérinaires, toilettage. Chaque rappel est lié à un animal et appartient à son
> propriétaire.
>
> Références : [ARCHITECTURE](../ARCHITECTURE.md) · [MOBILE](../MOBILE.md) ·
> [API](../API.md) · [DATA_MODEL](../DATA_MODEL.md) · [CONTRIBUTING](../CONTRIBUTING.md)

---

## 1. Ce qui existe déjà

### ⚙️ Backend — complet et compile (`com.petcare.agenda`)

| Fichier | Rôle |
|---------|------|
| `domain/AgendaItem.java` | Document MongoDB `agenda_items` : `ownerId`, `petId`, `type`, `title`, `notes`, `scheduledAt`, `reminderAt`, `status`, `recurrence` + audit |
| `domain/AgendaItemType.java` | `VACCINATION`, `DEWORMING`, `MEDICATION`, `VET_APPOINTMENT`, `GROOMING` |
| `domain/AgendaItemStatus.java` | `SCHEDULED`, `DONE`, `MISSED`, `CANCELLED` |
| `dto/AgendaItemRequest.java` · `AgendaItemResponse.java` · `UpdateAgendaStatusRequest.java` | Objets d'échange |
| `repository/AgendaItemRepository.java` | `findByOwnerId`, `findByOwnerIdAndType`, `findByPetId` |
| `service/AgendaService.java` + `AgendaServiceImpl.java` | create, list, getById, update, updateStatus, delete + contrôle de propriété + vérifie que l'animal existe |
| `controller/AgendaController.java` | Endpoints REST, rôle `PET_OWNER` |

**Endpoints disponibles :**
```
POST   /agenda                 créer un rappel / rendez-vous
GET    /agenda?type=...        lister (filtre par type)
GET    /agenda/{id}            détail
PUT    /agenda/{id}            modifier
PATCH  /agenda/{id}/status     changer le statut (DONE, CANCELLED…)
DELETE /agenda/{id}            supprimer
```

### 📱 Mobile — partiel (`lib/features/agenda/`)
- `presentation/agenda_page.dart` : écran **liste en lecture seule** (appelle `GET /agenda`).
- ❌ Manque : couches `data/` et `domain/`, écrans de création/édition/suppression, calendrier, filtres, notifications.

---

## 2. Ce qu'on doit faire — check-list

### Backend
- [ ] Filtre par période `from`/`to` sur `GET /agenda` (repository + service + controller).
- [ ] Exploiter `reminderAt` : mécanisme de rappel/notification (à cadrer : `@Scheduled` backend et/ou notifications locales mobile).
- [ ] Logique de **récurrence** (`recurrence`) : regénérer un rappel (ex. vermifuge tous les 3 mois).
- [ ] Tests du service (propriété, création liée à un animal, changement de statut).

### Mobile (Clean Architecture — voir [MOBILE.md](../MOBILE.md))
- [ ] `domain/` : entité `AgendaItem`, interface repository, use cases.
- [ ] `data/` : `AgendaApi` (dio) + models JSON + implémentation repository.
- [ ] `presentation/` : créer / modifier / supprimer un rappel (formulaires → POST/PUT/DELETE).
- [ ] `presentation/` : marquer fait / annulé (PATCH `/status`).
- [ ] `presentation/` : vue **calendrier** + liste « à venir ».
- [ ] `presentation/` : filtres par animal / type / période.
- [ ] **Notifications locales** (`flutter_local_notifications`) basées sur `reminderAt`.

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
# 1. Base de données
docker compose up -d

# 2. Backend
cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=local
#   API : http://localhost:8080/api/v1 · Swagger : http://localhost:8080/swagger-ui.html

# 3. Mobile
cd mobile && flutter pub get && flutter run
```
Détails complets dans [SETUP.md](../SETUP.md).
