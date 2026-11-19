---
name: android-app-dev
description: Use when creating, changing, building, testing or debugging an Android app (Kotlin, Jetpack Compose, Gradle, APK/AAB) in this repo – including "write an Android app", "add a screen", "fix the build", "why does Gradle fail". Covers environment check, scaffolding with the official template, build/test/lint commands, verification without an emulator, and which official Google skills to read.
---

# Android app development in this repo

## 1. Check the environment first

```bash
echo "ANDROID_HOME=$ANDROID_HOME"; ls "$ANDROID_HOME/platforms" 2>/dev/null; java -version 2>&1 | grep -v "Picked up" | head -1
```

If `ANDROID_HOME` is empty or `platforms/` is missing, run `scripts/android-setup.sh` (idempotent, ~30 s, installs cmdline-tools,
platform-tools, platform `37.0`, build-tools `36.0.0` into `/opt/android-sdk`), then
`export ANDROID_HOME=/opt/android-sdk PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"`.
Google's `android` CLI (in `cmdline-tools/latest/bin`) is available; always pass `--no-metrics`.

Official Google skills are installed by `scripts/android-skills.sh` into `.claude/skills/` (gitignored). If a task touches
edge-to-edge UI, Navigation 3, adaptive layouts, CameraX, Compose performance, XML→Compose migration, test setup, AGP upgrades,
R8, permissions/intent security or iOS→Android porting, **read the matching `.claude/skills/<name>/SKILL.md` before coding**.

## 2. New app

```bash
scripts/new-app.sh "Notiz Block" de.twitra.notizblock      # -> apps/notiz-block (official empty-activity template)
```

Template stack: Kotlin, Jetpack Compose + Material 3, Navigation 3, ViewModel + StateFlow, version catalog
(`gradle/libs.versions.toml`), AGP 9 (Kotlin support is built in: do **not** add `org.jetbrains.kotlin.android`),
`minSdk 26`, `compileSdk/targetSdk 37`. Keep this stack unless the user asks otherwise. UI strings go in `res/values/strings.xml`
(German first if the user writes German), never hard-coded in composables.

## 3. Build, test, lint

Run from the app folder (`apps/<slug>`):

```bash
./gradlew assembleDebug                  # APK: app/build/outputs/apk/debug/app-debug.apk
./gradlew testDebugUnitTest lintDebug    # JVM unit tests + lint (no device needed)
./gradlew :app:dependencies --configuration debugRuntimeClasspath | head -50    # dependency problems
```

Add `--no-daemon --max-workers=2` in the cloud container if memory is tight.

## 4. Verifying without an emulator

Cloud containers have **no `/dev/kvm`, so no emulator**. Verify with what exists, and say exactly what was and was not verified:

1. `assembleDebug` succeeds and the APK exists (`android analyze <apk>` lists size, permissions, components).
2. Unit tests for ViewModels/logic (`testDebugUnitTest`) – put logic in plain Kotlin classes so it is testable.
3. `lintDebug` with no new errors.
4. UI without a device (verified here): from the app's Gradle root run
   ```bash
   android --no-metrics preview list :app                      # prints the fully qualified @Preview names
   android --no-metrics preview render :app --fqn <fqn> -o /tmp/previews    # --fqn is required, repeatable
   ```
   The PNG lands in `<out>/<package path>/<File>Kt/<Name>_0.png` – open it with the Read tool and look at it. First use downloads
   a "preview pack". Give every screen a `@Preview` (with `showBackground = true`).
5. Instrumented tests (`androidTest`) and real device behaviour cannot run here – state that plainly, never claim "works on device".

## 5. Gotchas seen in this environment

- **HTTP 429 from Maven Central** (`repo.maven.apache.org`, shared proxy IP, Cloudflare): just re-run the same Gradle command.
  Gradle caches every artifact it did get, so each retry gets further. Do not change repositories or add global Gradle init
  scripts without asking the user.
- The template declares `jvmToolchain(17)`; it built fine here with only JDK 21 installed. If another machine reports
  "No matching toolchains", install a JDK 17 rather than editing the template.
- `compileSdk = 37` needs SDK platform `37.0` (`platforms;android-37.0`, note the `.0`).
- Never commit `local.properties`, keystores, `*.apk`, `*.aab`.

## 6. Looking things up

`android --no-metrics docs search "<query>"` searches the official Android knowledge base; `android --no-metrics docs fetch kb://<id>`
reads an article from a `kb://` URL returned by the search.
Before adding a dependency, check the real latest stable version (maven.google.com / Maven Central metadata), do not guess.

## 7. Definition of done

Build green, tests green, lint clean, a `@Preview` rendered for new screens, and a short honest report: what was built, which
commands ran, what could not be verified (emulator/device). Commit on the branch the session specifies; open a draft PR.
