# 📋 Pre-Release Checklist — Syndory Prof

## ✅ Développement

- [x] `flutter analyze` → 0 issues
- [x] `flutter pub get` → OK
- [x] Code review complétion (no mocks, clean imports)
- [x] API deprecations fixed (withOpacity → withValues)
- [x] Auth flow validated (Gate → Profile → MainShell)
- [x] Supabase config stricte (env vars only)

## 📱 Android

### Pre-build

- [ ] Vérifier [android/app/build.gradle.kts](android/app/build.gradle.kts) :
  - [ ] applicationId unique ?
  - [ ] versionCode ≥ 1 ?
  - [ ] versionName défini ?
- [ ] Vérifier [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) :
  - [ ] Permissions requises présentes ?
  - [ ] Internet permission OK ?
- [ ] Keystore généré + chemin configuré ?

### Build

- [ ] `flutter build apk --release` réussit ?
  - Cmd : `flutter build apk --release --dart-define SUPABASE_URL=... --dart-define SUPABASE_ANON_KEY=...`
- [ ] APK généré dans `build/app/outputs/flutter-apk/app-release.apk` ?
- [ ] APK size acceptable (< 100 MB) ?

### Testing

- [ ] Install APK sur device de test
- [ ] Login flow OK (email → password → dashboard)
- [ ] Profile loads correctly
- [ ] Navigation complète (all tabs accessible)
- [ ] No crashes on home screen

## 🍎 iOS

- [ ] Build compiles (`flutter build ios`)
- [ ] Basic navigation tested (simulator)

## 🌐 Web

- [ ] Build compiles (`flutter build web`)
- [ ] Home page loads

## ☁️ Supabase Configuration

- [ ] SUPABASE_URL correct pour l'env ?
- [ ] SUPABASE_ANON_KEY correct pour l'env ?
- [ ] RLS policies vérifiées ?
- [ ] Professors table a la colonne `is_active` ?
- [ ] Auth role (professor/admin) déclaré ?
- [ ] Edge Functions deployées (justifications) ?

## 🔐 Sécurité

- [ ] Pas de secrets hardcodés en code source
- [ ] Pas de tokens/clés en .dart files
- [ ] release mode build (obfuscation enabled)
- [ ] Version Flutter/Dart à jour

## 📊 Staging Deployment

- [ ] Deploy APK sur internal testing track (Google Play)
- [ ] 24h de monitoring → pas de crash
- [ ] QA team validation → sign-off
- [ ] Stakeholder approval → green light

## 🚀 Production Release

- [ ] All staging checks passed
- [ ] Release notes prepared
- [ ] Rollout phase 1 (5% users, 24h monitoring)
- [ ] Rollout phase 2 (50% users, 48h monitoring)
- [ ] Full rollout (100% users)

---

## 🚨 Emergency Plan

Si crash en production :

1. Pause rollout → `Stop all traffic`
2. Check logs → Firebase/Crashlytics
3. Revert to previous version
4. Patch + test on staging
5. Restart rollout with staged approach

---

**Last Updated** : 7 mai 2026  
**Owner** : Syndory Team
