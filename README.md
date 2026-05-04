# Syndory — Application Professeur (Flutter)

## Architecture du repository

```
.
├─ android/
├─ lib/
│  ├─ main.dart
│  ├─ app/            # bootstrap, navigation, theme, gestion d’erreurs
│  ├─ data/           # accès Supabase + wrappers + types
│  ├─ shared/         # widgets/utilitaires communs
│  └─ features/       # modules (écrans/flows)
├─ test/
├─ pubspec.yaml
└─ .env.example
```

Note : plusieurs fichiers `placeholder.dart` présents dans `lib/features/*` sont des **placeholders** (scaffold) :

- ils servent uniquement à stabiliser l’arborescence et les imports au début du projet
- ils devront être **remplacés ou supprimés** quand les modules réels seront implémentés

## Prérequis

- Flutter SDK (canal stable)
- Android Studio (ou VS Code) + Android SDK
- Un device Android ou un émulateur
- Java JDK 17 (requis pour builder Android)

Configuration JDK (local, à ne pas committer) :

- Android Studio : **Gradle JDK** → sélectionner un JDK 17
- Ou définir `JAVA_HOME` vers un JDK 17
- Ou ajouter `org.gradle.java.home=...` dans `~/.gradle/gradle.properties`

## Configuration ENV

Ce projet utilise Supabase (Auth, Database, Storage, Edge Functions).

Les secrets ne doivent pas être commit.

Variables attendues (adapter les noms si l’app utilise une autre convention) :

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Un fichier template est fourni : `.env.example`.

### Injection via `--dart-define` (recommandé)

L’app lit `SUPABASE_URL` et `SUPABASE_ANON_KEY` via `String.fromEnvironment(...)`.

Exemple (remplacer par tes valeurs Supabase) :

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Pour une build APK release :

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

## Lancer l’application

- Installer les dépendances :

  ```bash
  flutter pub get
  ```

- Lancer en debug :

  ```bash
  flutter run
  ```

- Construire un APK release :

  ```bash
  flutter build apk --release
  ```

## Contribution

Les règles de contribution (branches, PR, commits) sont décrites dans :

- `CONVENTIONS-REPOSITORY.md`

### Conventions Git (résumé)

- Branches :
  - `main` : stable / production (pas de push direct)
  - `develop` : intégration (PR obligatoires)
  - `feature/<name>` : nouvelles fonctionnalités
  - `fix/<name>` : corrections
- Règle : chaque feature passe par une Pull Request.
- Règle : aucun secret (keys, `.env`, keystores) ne doit être committé.

## Backend integration (Supabase)

Références :

- `SUPABASE-BACKEND-DOCUMENTATION.md`
- `docs/database.md`
- `docs/edge-functions.md`

### Variables

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Auth

Le projet utilise **Supabase Auth** (pas de endpoint custom `POST /auth/login`).

- Login : `supabase.auth.signInWithPassword({ email, password })`
- Logout : `supabase.auth.signOut()`

### RLS

Toutes les tables applicatives ont **RLS activée**.

- Côté frontend, on utilise uniquement la **anon key**.
- Si un CRUD échoue (401/403), c’est souvent que l’opération doit passer par une Edge Function.

### Edge Functions (principales)

Base URL : `https://<project-ref>.supabase.co/functions/v1/<function-name>`

Pour l’app professeur, les fonctions typiquement utilisées incluent :

- `open-session`
- `close-session`
- `review-justification`
- `update-progression`
- `validate-progression`

### Storage buckets

- `avatars` (public)
- `resources` (private)
- `justificatifs` (private)
- `annonces` (private)

## Debug / Health

Un écran `Debug / Health` est fourni pour valider le setup :

- init Supabase (config présente ou non)
- statut auth (connecté / non connecté)
- test de lecture non destructif (nécessite un login à cause de RLS)

## Qualité (format / lint)

- Format (commande unique) :

  ```bash
  dart format .
  ```

- Analyse (commande unique) :

  ```bash
  flutter analyze
  ```

- Vérification complète (format + analyze) :

  ```bash
  dart format . && flutter analyze
  ```
