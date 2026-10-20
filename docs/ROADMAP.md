# 🗺️ Roadmap — Pet-Care

Phases de livraison proposées et évolutions futures.

---

## Phase 0 — Fondations (socle technique) ✅

- [x] Architecture définie (backend modulaire + mobile Clean Architecture).
- [x] Structure du dépôt, documentation, environnement Docker (MongoDB).
- [ ] Squelette backend compilable + sécurité JWT fonctionnelle.
- [ ] Squelette mobile : navigation, thème, auth.

## Phase 1 — MVP (parcours propriétaire)

- [ ] **User** : signup / login / profil (PET_OWNER).
- [ ] **Pets** : CRUD complet des profils animaux + photo.
- [ ] **Dossier médical** : consultation en lecture pour le propriétaire.
- [ ] **Agenda** : création de rappels + notifications locales.

## Phase 2 — Vétérinaire & médical

- [ ] Rôle **VET** : association vétérinaire ↔ animaux suivis.
- [ ] Dossier médical en écriture (consultations, vaccins, allergies, médicaments).
- [ ] Rappels de vaccination/vermifuge automatiques depuis le dossier.

## Phase 3 — Marketplace

- [ ] Catalogue produits (4 catégories) + recherche / filtres.
- [ ] Panier et passage de commande.
- [ ] Suivi des commandes + gestion admin du catalogue.
- [ ] (Ultérieur) intégration d'un paiement (Stripe / autre).

## Phase 4 — Événements & communauté

- [ ] Catalogue d'événements + inscription.
- [ ] Gestion de la capacité et des participants.
- [ ] Notifications d'événements à proximité.

## Phase 5 — Administration & qualité

- [ ] Espace admin complet (utilisateurs, rôles, modération).
- [ ] Tableaux de bord / statistiques.
- [ ] Couverture de tests (backend + mobile) et CI/CD.

---

## Évolutions futures envisagées

| Thème | Idée |
|-------|------|
| **Stockage fichiers** | Upload des photos vers un object storage (S3/GCS) + CDN. |
| **Notifications push** | Firebase Cloud Messaging pour rappels et événements. |
| **Temps réel** | Chat propriétaire ↔ vétérinaire (WebSocket). |
| **Paiement** | Intégration d'un prestataire de paiement pour la marketplace. |
| **Télé-consultation** | Visio vétérinaire intégrée. |
| **IA** | Suggestions de soins, détection d'anomalies sur le dossier médical. |
| **Internationalisation** | Multilingue (FR/EN/…), multidevise marketplace. |
| **Microservices** | Extraction de `marketplace` / `event` en services autonomes si besoin de scaling. |
| **Observabilité** | Logs centralisés, métriques (Prometheus/Grafana), tracing. |
