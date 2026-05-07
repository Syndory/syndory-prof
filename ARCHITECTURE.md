# 🎯 Architecture Overview — Syndory Prof

## Project Structure

```
lib/
├── main.dart                          # Entry point (Riverpod ProviderScope)
├── app/
│   ├── app_bootstrap.dart            # Root widget + Supabase guard
│   ├── env/
│   │   └── app_env.dart              # Config from env vars
│   ├── errors/
│   │   └── missing_supabase_config_screen.dart
│   ├── navigation/
│   │   └── main_shell.dart           # BottomNav shell
│   ├── providers/
│   │   └── supabase_providers.dart   # Riverpod state (client, auth, user, profile)
│   └── theme/
│       └── app_theme.dart            # Material theme
├── data/
│   ├── models/                       # Domain models (SeanceModel, etc.)
│   ├── repositories/                 # Data layer (Supabase + Edge Functions)
│   ├── supabase/
│   │   └── supabase_client.dart      # Singleton Supabase client
│   └── types/                        # Enums (UserRole, JustificationStatus, etc.)
├── features/
│   ├── auth/
│   │   ├── auth_gate.dart           # Protection + role validation
│   │   ├── auth_routes.dart         # Routing
│   │   └── login_screen.dart        # Email/password form
│   ├── accueil/                      # Home screen
│   │   ├── accueil_page.dart        # Main widget
│   │   ├── accueil_loaded.dart      # Models + UI
│   │   ├── accueil_repository.dart
│   │   └── models/
│   ├── session/
│   │   ├── active_session_screen.dart   # Timer + attendance
│   │   ├── pre_session_screen.dart
│   │   └── session_recap_screen.dart    # Stats recap
│   ├── justifications/
│   │   ├── data/
│   │   │   └── justification_repository.dart
│   │   └── presentation/
│   ├── notifications/
│   │   └── notifications_screen.dart    # Backend-only (no mocks)
│   ├── calendar/
│   ├── classes/
│   ├── schedule/
│   ├── profile/
│   ├── settings/
│   ├── stats/
│   ├── resources/
│   ├── progress/
│   ├── home/
│   └── attendance/
├── shared/
│   └── widgets/                      # Reusable UI components
└── accueil/                          # Legacy home screen (keep for now)
```

---

## Key Concepts

### 1. State Management (Riverpod)

**Providers are defined in** `lib/app/providers/supabase_providers.dart` :

```dart
// Client
final supabaseClientProvider = Provider((ref) => SupabaseClientProvider.client);

// Auth stream
final authStateChangesProvider = StreamProvider((ref) {
  return SupabaseClientProvider.client.auth.onAuthStateChange;
});

// Current session
final currentSessionProvider = Provider((ref) {
  return SupabaseClientProvider.client.auth.currentSession;
});

// Current user
final currentUserProvider = Provider((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.user;
});

// Full user profile (fetched on auth change)
final currentUserProfileProvider = FutureProvider((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return UserRepository.getCurrentProfile();
});
```

**Usage in UI** :

- For StatelessWidget → use `ConsumerWidget` + `ref.watch(provider)`
- For StatefulWidget → use `ConsumerStatefulWidget` + `ref.watch(provider)` in build

### 2. Data Layer

**Repositories handle all Supabase interaction** :

- `AccueilRepository.fetchAccueilData()` → Home data
- `UserRepository.getCurrentProfile()` → Profile + role
- `JustificationRepository.*` → Justifications + Edge Functions
- `ClassesRepository.getProfessorClasses()` → Classes + students

**Never call Supabase client directly from UI** :

```dart
// ❌ WRONG
final data = await SupabaseClientProvider.client.from('users').select().single();

// ✅ RIGHT
final data = await UserRepository.getCurrentProfile();
```

### 3. Auth Flow

1. **main.dart** → Check Supabase config
2. **AppBootstrap** → If config missing, show error screen
3. **AuthGate** → StreamBuilder on auth state
   - If no session → LoginScreen
   - If session → Load profile (Future)
   - If profile loaded → Validate role (professor/admin only)
   - If valid → MainShell (home)

### 4. Error Handling

**Expected errors** :

- Missing Supabase config → MissingSupabaseConfigScreen (shown in app_bootstrap)
- Missing profile → \_ErrorScreen (shown in auth_gate)
- Wrong role → \_ErrorScreen (shown in auth_gate)
- Profile inactive → \_ErrorScreen (shown in auth_gate)

**Unhandled errors** :

- Use `try/catch` in repositories
- Use `FutureBuilder` or `StreamBuilder` error state in UI
- Log errors with `debugPrint()` for debugging

---

## Development Guidelines

### Adding a New Feature

1. **Create feature directory** : `lib/features/my_feature/`
2. **Create data layer** :
   - `data/my_feature_repository.dart`
   - `data/models/my_model.dart`
3. **Create presentation** :
   - `presentation/my_feature_screen.dart`
4. **Integrate with auth** : If requires user context, use AuthGate checks
5. **Add to MainShell navigation** if needed

### Calling Supabase

```dart
// In repository ONLY
class MyRepository {
  static Future<MyModel> fetchData(String userId) async {
    final response = await SupabaseClientProvider.client
        .from('my_table')
        .select()
        .eq('user_id', userId)
        .single();
    return MyModel.fromJson(response);
  }

  static Future<void> updateData(String id, Map<String, dynamic> data) async {
    await SupabaseClientProvider.client
        .from('my_table')
        .update(data)
        .eq('id', id);
  }
}
```

### Using Riverpod

```dart
// In a ConsumerWidget
class MyScreen extends ConsumerWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);

    return profile.when(
      data: (p) => Text('Hello, ${p.firstName}'),
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
    );
  }
}
```

---

## Best Practices

✅ **DO**

- Use repositories for all Supabase calls
- Check `mounted` before `setState()` after async operations
- Dispose controllers (TextEditingController, ScrollController, etc.)
- Use `const` constructors where possible
- Comment non-obvious logic

❌ **DON'T**

- Call Supabase client directly from UI
- Hardcode secrets or URLs
- Use `!` force unwrap without prior null check
- Create large StatelessWidgets (extract to smaller components)
- Leave unused imports or variables

---

## Testing

### Unit Tests

- Test repositories in isolation
- Mock Supabase client
- Example : `test/notification_models_test.dart`

### Widget Tests

- Test UI rendering + interactions
- Example : `test/notifications_screen_test.dart`

### E2E Tests (Manual for now)

1. Install APK on device
2. Walk through auth flow
3. Check each feature (sessions, justifications, etc.)

---

## Deployment

See [PRE_RELEASE_CHECKLIST.md](PRE_RELEASE_CHECKLIST.md) and [PROD_READINESS_REPORT.md](PROD_READINESS_REPORT.md).

Build command :

```bash
flutter build apk --release \
  --dart-define SUPABASE_URL=... \
  --dart-define SUPABASE_ANON_KEY=...
```

---

## Useful Commands

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Check dependencies
flutter pub outdated

# Update dependencies
flutter pub upgrade
```

---

**Last Updated** : 7 mai 2026
