# CraftAnything – Android-Werkstatt

Eigene Android-Apps in Kotlin und Jetpack Compose – geschrieben, gebaut und getestet mit Claude Code. GitHub baut daraus automatisch fertige `.apk`-Dateien, so wie im Schwesterrepo `programme` die `.exe`-Dateien entstehen.

## Was Claude hier kann

| Du sagst … | Claude nutzt |
|---|---|
| „Bau mir eine Einkaufslisten-App“ | Skill `android-app-dev` + offizielle Google-Vorlage (`scripts/new-app.sh`) |
| „Hol dir `github.com/…/app` und bau sie“ | Skill `android-app-clone`, Pfad A (`scripts/clone-app.sh`) |
| „Mach eine App wie X, aber meine eigene“ | Skill `android-app-clone`, Pfad B (Clean-Room-Nachbau mit eigenem Namen/Icon) |
| „Portiere diese iOS-App“ | offizieller Google-Skill `ios-to-android` |
| „Schau dir an, wie diese Website/App funktioniert“ | Skill `craft-anything` ([storytold/craft-anything](https://github.com/storytold/craft-anything)) |
| „Bring die App in den Play Store / als Release“ | Skill `android-release` |

## Aufbau

```
apps/hallo-android/    Beispiel-App (mit scripts/new-app.sh erzeugt, gebaut, getestet)
apps/<name>/           weitere Apps: je eine Gradle-Wurzel
clones/                fremde Projekte (gitignored)
scripts/               android-setup.sh · android-skills.sh · new-app.sh · clone-app.sh · install-craft-anything.sh
.claude/skills/        android-app-dev · android-app-clone · android-release · craft-anything
.claude/hooks/         session-start.sh (richtet jede Cloud-Session ein – siehe unten)
.mcp.json              Craft-Anything-MCP-Server (Clean-Room-Modus)
.github/workflows/     android.yml
CLAUDE.md              Arbeitsregeln für Claude in diesem Repo
```

## Was eingerichtet wird

1. **Android SDK** (`scripts/android-setup.sh`): cmdline-tools, platform-tools, Plattform 37.0, build-tools 36.0.0 nach `/opt/android-sdk` (ca. 30 s). Dazu Googles `android`-CLI (Projektvorlagen, `preview`, `analyze`, `docs`).
2. **Offizielle Google-Skills** (`scripts/android-skills.sh`): 14 ausgewählte aus 37 – u. a. `ios-to-android`, `navigation-3`, `edge-to-edge`, `adaptive`, `camerax`, `testing-setup`, `r8-analyzer`. Sie landen in `.claude/skills/` und sind gitignored (werden bei Bedarf neu geholt). Alle anzeigen: `scripts/android-skills.sh --list`.
3. **Craft Anything** (`scripts/install-craft-anything.sh`): CLI in Version **v0.6.1**, fest gepinnt mit SHA-256-Prüfung. Bei Abweichung wird nichts installiert.

## Prüfen ohne Emulator

Cloud-Sessions haben keine KVM, also keinen Emulator. Geprüft wird mit: `./gradlew assembleDebug testDebugUnitTest lintDebug` und `android preview render` (rendert `@Preview`-Composables ohne Gerät zu PNG). Verhalten auf einem echten Gerät lässt sich hier nicht testen – Claude soll das im Bericht offen sagen.

## APK bekommen

1. Änderung nach `main` pushen → **Actions** baut jede App unter `apps/`, führt Tests und Lint aus.
2. Die APK liegt im Lauf unter **Artifacts → `<app>-debug-apk`**.
3. Feste Version: Tag `v1.0.0` setzen → APK wird an das Release gehängt.
4. Aufs Handy: APK herunterladen, „Unbekannte Apps installieren“ für den Browser erlauben, öffnen. (Debug-signiert, nur zum Ausprobieren. Für Play Store siehe Skill `android-release`.)

## SessionStart-Hook

`.claude/hooks/session-start.sh` installiert SDK, Skills und Craft Anything beim Start jeder Cloud-Session. Er läuft nur dort (`CLAUDE_CODE_REMOTE`), überspringt Fertiges (erster Lauf ca. 22 s, danach unter 1 s) und läuft synchron: Die Session startet erst, wenn er fertig ist. Registriert ist er in `.claude/settings.json`; die Datei enthält nur diese Hook-Registrierung und keine Berechtigungsregeln.

Der Hook wirkt in Sessions, sobald `.claude/settings.json` auf dem Standard-Branch des Repos liegt (nach dem Merge). Abschalten: den `hooks`-Block aus der `settings.json` löschen. Claude ruft die Skripte dann bei Bedarf selbst auf (steht so in den Skills).

## Craft Anything – Hinweise

- Offenes Projekt (Apache-2.0), laut eigener Aussage **früh im Alpha-Stadium**. Ergebnisse immer gegenprüfen.
- Standard ist der **Clean-Room-Modus**: Es liest nichts aus dem Inneren des Ziels (kein Code, keine Dateien), sondern arbeitet mit dem, was man sieht.
- **Deep-Modus** (Dekompilieren, Code lesen) nur für eigene Apps, Open Source oder mit Erlaubnis des Rechteinhabers. Fremde Apps zu dekompilieren kann Urheberrecht und Lizenzbedingungen verletzen (in Deutschland nur eng erlaubt, z. B. §69e UrhG).
- Update auf eine neue Version: `VERSION` und `SHA256` in `scripts/install-craft-anything.sh` ändern (Prüfsumme steht im Release in `SHA256SUMS.txt`).
- `rebuild` und `chat` brauchen einen auf demselben Rechner angemeldeten Coding-Agenten; in der Cloud meist nicht vorhanden. Dann übernimmt Claude den Bauteil selbst.

## Bekannte Grenzen

- Maven Central antwortet in der Cloud gelegentlich mit HTTP 429 (Drosselung). Denselben Gradle-Befehl einfach noch einmal starten; Gradle behält bereits geladene Dateien.
- Die Vorlage kommt von Google (AGP 9.0.1, Kotlin 2.3.20). Neuere Versionen übernimmt man gezielt, nicht nebenbei.
