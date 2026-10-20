# 📱 Pet-Care — Application mobile (Flutter)

Application cliente de la plateforme Pet-Care. Architecture détaillée dans
[../docs/MOBILE.md](../docs/MOBILE.md).

## Démarrage

```bash
flutter pub get
flutter run --flavor dev           # ou simplement: flutter run
```

> L'URL de l'API est définie dans `lib/core/config/app_config.dart`.
> Émulateur Android : `http://10.0.2.2:8080/api/v1`. Simulateur iOS / web : `http://localhost:8080/api/v1`.

## Structure

```
lib/
├── main.dart                 # Bootstrap (ProviderScope, thème, router)
├── core/                     # Transverse : config, network, theme, router, di, widgets, error
└── features/                 # Une tranche par fonctionnalité (data / domain / presentation)
    ├── auth/                  # Connexion, inscription, état d'authentification
    ├── pets/                  # Liste + détail des animaux, ajout
    ├── medical_record/        # Dossier médical (consultations, vaccins, allergies, médicaments)
    ├── marketplace/           # Catalogue produits
    ├── agenda/                # Rappels de soins
    └── events/                # Événements communautaires
```

## Stack

| Besoin | Paquet |
|--------|--------|
| État | `flutter_riverpod` |
| Navigation | `go_router` |
| HTTP | `dio` (intercepteur JWT + refresh) |
| Stockage sécurisé | `flutter_secure_storage` |

## Tests

```bash
flutter test
flutter analyze
```

## Note

Les écrans « panier » et « inscription aux événements » sont volontairement
laissés comme points d'extension (voir [../docs/ROADMAP.md](../docs/ROADMAP.md)).
