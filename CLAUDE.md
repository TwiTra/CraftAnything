# Android-Werkstatt

Eigene Android-Apps (Kotlin + Jetpack Compose). Dieses Repo ist so eingerichtet, dass Claude Code hier Android-Apps schreiben,
bauen, testen und bekannte Projekte klonen/nachbauen kann. Antworte dem Nutzer auf Deutsch.

## Aufbau

```
apps/<name>/           eine Gradle-Wurzel pro App (Vorlage: scripts/new-app.sh)
clones/                fremde Open-Source-Projekte (scripts/clone-app.sh) – gitignored
scripts/               android-setup.sh, android-skills.sh, new-app.sh, clone-app.sh, install-craft-anything.sh
.claude/skills/        android-app-dev, android-app-clone, android-release, craft-anything (+ offizielle Google-Skills, gitignored)
.claude/hooks/         session-start.sh (installiert SDK, Skills, Craft Anything; siehe README zum Aktivieren)
.mcp.json              Craft-Anything-MCP-Server im Clean-Room-Modus
.github/workflows/     android.yml – baut jede App und legt die APK als Artifact ab
```

## Immer so

1. Vor dem ersten Build: `ls "$ANDROID_HOME/platforms"`; fehlt es, `scripts/android-setup.sh` ausführen.
2. Skills benutzen: `android-app-dev` für Bauen/Testen, `android-app-clone` bevor irgendetwas "geklont" wird, `craft-anything` für dessen Werkzeuge.
3. Keine Emulator-Behauptungen: Cloud-Sessions haben keine KVM. Verifiziert wird per Build, Unit-Tests, Lint und `android preview render`.
   Im Bericht klar trennen, was geprüft wurde und was nicht.
4. Fremde Apps nur nach den Regeln in `android-app-clone` (Lizenz prüfen, eigener Name/Icon, Deep-Modus/Dekompilieren nur mit Bestätigung).
5. Nie committen: `local.properties`, Keystores, `*.apk`, `*.aab`, Passwörter.
6. Maven Central liefert in der Cloud gelegentlich HTTP 429: denselben Gradle-Befehl einfach erneut starten.
