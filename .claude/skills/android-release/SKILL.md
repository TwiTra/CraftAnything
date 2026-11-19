---
name: android-release
description: Use when the user wants to ship an Android app – signed release APK/AAB, versioning, R8 shrinking, GitHub Actions build artifacts, GitHub Releases, or Google Play requirements. Not for debug builds (see android-app-dev).
---

# Releasing an Android app

## Choose the target

| Goal | Output | Notes |
|---|---|---|
| Try on own phone / share with friends | **debug APK** from CI artifact | `./gradlew assembleDebug`; debug-signed, sideload only |
| Stable sideload build | **signed release APK** | needs a keystore the user owns |
| Google Play | **signed AAB** (`bundleRelease`) | Play App Signing; target API must meet Play's current requirement – check with the `play-policy-insights` skill / `android docs` |

## Steps

1. Bump `versionCode` (integer, always increasing) and `versionName` in `app/build.gradle.kts`.
2. Turn on shrinking for release: `isMinifyEnabled = true` (+ `isShrinkResources = true`); read `.claude/skills/r8-analyzer` and add keep rules
   only where needed; test the release build, minified apps crash differently.
3. Signing: create the keystore **on the user's machine**, never in a cloud session and never in git
   (`keytool -genkeypair -v -keystore release.jks -alias upload -keyalg RSA -keysize 4096 -validity 10000`).
   In CI read it from GitHub secrets (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`), decode to a temp file, point
   `signingConfigs.release` at it through environment variables. **Tell the user to back up the keystore – losing it means no more updates.**
4. `./gradlew bundleRelease assembleRelease`, then `android analyze app/build/outputs/...` to check size/permissions.
5. Tag `vX.Y.Z` to let CI attach artifacts to a GitHub Release (see `.github/workflows/android.yml`).

## Checklist before publishing

- Own app name, icon, package id; no third-party trademarks or assets (see `android-app-clone`).
- Only permissions that are used; runtime permission flows tested (`android-permissions-security` skill).
- Privacy policy URL and data-safety answers if on Play.
- State what was and was not tested on real devices.
