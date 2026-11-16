## 🔀 Branche cible
- [ ] Cette PR va de `feature/*` → **`dev`**, ou de `dev` → **`main`**.
  *(Aucune autre PR vers `main` n'est acceptée — voir le workflow `enforce-pr-base`.)*

## 📝 Description
<!-- Contexte et objectif de la PR : que fait-elle, pourquoi ? -->

## 🔧 Ce qui change
<!-- Liste des changements principaux -->
-

## ✅ Checklist (à cocher AVANT de demander une revue)
- [ ] Le code **compile** (`cd backend && mvn -q compile` et/ou `cd mobile && flutter analyze`)
- [ ] Les **tests** passent si applicable (`mvn test` / `flutter test`)
- [ ] **Conventional Commits** respectés, **sans aucune mention d'outil d'IA**
      (pas de `Co-Authored-By`, pas de « Generated with… », pas de lien de session)
- [ ] Mon module **ne modifie pas** le code d'un autre module
      (tout ajout au socle commun est signalé ci-dessous)
- [ ] Backend : **DTO** utilisés (documents MongoDB jamais exposés directement),
      validation `@Valid` sur les entrées
- [ ] **Testé manuellement** (étapes décrites ci-dessous)
- [ ] Documentation mise à jour si nécessaire (`docs/…`)

## 🧪 Comment tester
<!-- Étapes précises pour qu'un relecteur reproduise le test -->
1.

## 📸 Captures d'écran (si changement d'UI)
<!-- Avant / après -->

## ⚠️ Modifications du socle commun (le cas échéant)
<!-- Fichiers core/ ou common/ touchés + justification -->
