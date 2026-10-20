# 🐾 Pet-Care

> Plateforme mobile de gestion et de services dédiée aux animaux de compagnie :
> suivi de santé, dossier médical, marketplace, agenda de soins et événements
> communautaires — le tout dans une seule application, avec un espace personnalisé
> selon le rôle de l'utilisateur (Administrateur, Propriétaire d'animal, Vétérinaire).

<p align="center">
  <img src="https://img.shields.io/badge/mobile-Flutter-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/backend-Spring_Boot_3-6DB33F?logo=springboot" alt="Spring Boot">
  <img src="https://img.shields.io/badge/database-MongoDB-47A248?logo=mongodb" alt="MongoDB">
  <img src="https://img.shields.io/badge/auth-JWT-000000?logo=jsonwebtokens" alt="JWT">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License">
</p>

---

## 🎯 Objectif

Regrouper dans une seule plateforme tous les services essentiels au bien-être des
animaux de compagnie, tout en facilitant les interactions entre **propriétaires**,
**vétérinaires** et la **communauté** des passionnés d'animaux.

## 🧩 Modules fonctionnels

| Module | Description | Documentation |
|--------|-------------|---------------|
| 👤 **User** | Authentification, inscription, gestion des comptes et des rôles (Admin, PetOwner, Vet). | [MODULES.md](docs/MODULES.md#1-module-user) |
| 🐶 **Pets** | Profils des animaux : nom, race, âge, sexe, poids, couleur, photo, puce, statut. | [MODULES.md](docs/MODULES.md#2-module-pets) |
| 🩺 **Dossier médical** | Historique médical, vaccinations, allergies, médicaments. | [MODULES.md](docs/MODULES.md#3-module-dossier-médical) |
| 🛒 **Marketplace** | Boutique : nourriture, accessoires, jouets, hygiène, panier et commandes. | [MODULES.md](docs/MODULES.md#4-module-marketplace) |
| 📅 **Agenda** | Rappels : vaccination, vermifuge, médicaments, rendez-vous, toilettage. | [MODULES.md](docs/MODULES.md#5-module-agenda) |
| 🎉 **Événements** | Promenades collectives, concours de beauté, journées santé, adoption, ateliers. | [MODULES.md](docs/MODULES.md#6-module-événements) |

## 🏗️ Architecture en bref

```
┌───────────────────────────┐        HTTPS / REST (JSON) + JWT        ┌───────────────────────────┐
│      Application mobile    │ ─────────────────────────────────────▶ │       API Backend          │
│          (Flutter)         │ ◀───────────────────────────────────── │       (Spring Boot)        │
│  Clean Arch / feature-first│                                         │   Monolithe modulaire      │
└───────────────────────────┘                                         └─────────────┬─────────────┘
                                                                                     │ Spring Data
                                                                                     ▼
                                                                        ┌───────────────────────────┐
                                                                        │         MongoDB            │
                                                                        │   (base documentaire)      │
                                                                        └───────────────────────────┘
```

Détails complets : **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**.

## 📂 Structure du dépôt

```
Pet-Care/
├── backend/          # API REST — Spring Boot 3 (Java 17) + MongoDB
├── mobile/           # Application Flutter (Dart) — Clean Architecture
├── docs/             # Documentation détaillée (architecture, API, modèle de données…)
├── docker-compose.yml# MongoDB + Mongo Express pour le développement local
└── README.md         # Ce fichier
```

## 🚀 Démarrage rapide

> Guide complet et pas-à-pas : **[docs/SETUP.md](docs/SETUP.md)**.

```bash
# 1. Lancer la base de données (MongoDB + interface Mongo Express)
docker compose up -d

# 2. Démarrer le backend
cd backend
./mvnw spring-boot:run          # API sur http://localhost:8080

# 3. Démarrer l'application mobile
cd ../mobile
flutter pub get
flutter run                     # choisir un émulateur / appareil
```

## 📚 Documentation

| Document | Contenu |
|----------|---------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Vue d'ensemble, choix techniques, diagrammes, flux. |
| [MODULES.md](docs/MODULES.md) | Détail fonctionnel et technique de chaque module. |
| [DATA_MODEL.md](docs/DATA_MODEL.md) | Collections MongoDB, schémas, relations, index. |
| [API.md](docs/API.md) | Référence des endpoints REST (routes, rôles, exemples). |
| [SECURITY.md](docs/SECURITY.md) | Authentification JWT, rôles et permissions (RBAC). |
| [MOBILE.md](docs/MOBILE.md) | Architecture de l'app Flutter, navigation, state management. |
| [SETUP.md](docs/SETUP.md) | Installation de l'environnement de développement. |
| [ROADMAP.md](docs/ROADMAP.md) | Phases de livraison et évolutions futures. |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | Conventions de code, branches, commits, PR. |

## 👥 Rôles utilisateurs

| Rôle | Accès principal |
|------|-----------------|
| **ADMIN** | Supervision globale : utilisateurs, catalogue marketplace, événements, modération. |
| **PET_OWNER** | Gère ses animaux, consulte leurs dossiers médicaux, commande, planifie, participe aux événements. |
| **VET** | Accède aux dossiers médicaux des animaux suivis, ajoute consultations, vaccins, prescriptions. |

## 📄 Licence

Distribué sous licence **MIT**. Voir [LICENSE](LICENSE).
