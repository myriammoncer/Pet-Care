# ⚙️ Installation & démarrage — Pet-Care

Guide pas-à-pas pour mettre en place l'environnement de développement.

---

## 1. Prérequis

| Outil | Version recommandée | Vérification |
|-------|--------------------|--------------|
| **JDK** | 17+ | `java -version` |
| **Maven** | 3.9+ (ou wrapper `./mvnw`) | `mvn -version` |
| **Flutter SDK** | 3.x | `flutter --version` |
| **Docker + Docker Compose** | récent | `docker --version` |
| **Git** | récent | `git --version` |

> Astuce : exécuter `flutter doctor` pour vérifier l'environnement mobile
> (Android SDK, Xcode sur macOS, émulateurs).

## 2. Cloner le projet

```bash
git clone https://github.com/myriammoncer/Pet-Care.git
cd Pet-Care
```

## 3. Base de données (MongoDB)

Un `docker-compose.yml` fournit MongoDB + une interface web.

```bash
docker compose up -d        # démarre MongoDB (27017) + Mongo Express (8081)
docker compose ps           # vérifier l'état
```

- MongoDB : `mongodb://petcare:petcare@localhost:27017/petcare?authSource=admin`
- Interface d'admin : http://localhost:8081

Pour arrêter : `docker compose down` (ajouter `-v` pour effacer les données).

## 4. Backend (Spring Boot)

```bash
cd backend

# Variables d'environnement (profil local)
export JWT_SECRET="dev-secret-change-me-please-256-bits-minimum-length-xxxxx"
export MONGODB_URI="mongodb://petcare:petcare@localhost:27017/petcare?authSource=admin"

# Lancer en profil local
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
```

- API disponible sur **http://localhost:8080/api/v1**
- Swagger UI : **http://localhost:8080/swagger-ui.html**
- Health check : **http://localhost:8080/actuator/health**

### Compilation / tests

```bash
./mvnw clean verify        # compile + exécute les tests
./mvnw test                # tests uniquement
```

## 5. Mobile (Flutter)

```bash
cd mobile
flutter pub get            # récupère les dépendances

# (si modèles freezed/json) générer le code
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer sur un émulateur / appareil connecté
flutter devices            # liste les cibles
flutter run --flavor dev
```

> L'URL de l'API est définie dans `mobile/lib/core/config/`.
> - Émulateur Android : `http://10.0.2.2:8080/api/v1` (10.0.2.2 = localhost de l'hôte)
> - Simulateur iOS / web : `http://localhost:8080/api/v1`

### Tests mobile

```bash
flutter test               # tests unitaires + widgets
flutter analyze            # analyse statique (lints)
```

## 6. Ordre de démarrage recommandé

```
1. docker compose up -d        (MongoDB)
2. backend : ./mvnw spring-boot:run -Dspring-boot.run.profiles=local
3. mobile  : flutter run --flavor dev
```

## 7. Données de démonstration (seed)

Au premier démarrage (profil `local`), un initialiseur crée un compte
administrateur par défaut et quelques produits/événements de test
(voir `common/config/DataSeeder`). Identifiants admin par défaut :

```
email    : admin@petcare.app
password : Admin123! (à changer immédiatement)
```

## 8. Dépannage

| Problème | Solution |
|----------|----------|
| `Connection refused` MongoDB | Vérifier `docker compose ps`, le port 27017 libre. |
| `401` systématique côté mobile | Vérifier `baseUrl` et l'horloge (expiration JWT). |
| Émulateur Android ne joint pas l'API | Utiliser `10.0.2.2` au lieu de `localhost`. |
| Port 8080 occupé | Changer `server.port` dans `application.yml`. |
| Erreurs de build Flutter sur modèles | Relancer `build_runner build --delete-conflicting-outputs`. |
