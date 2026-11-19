#!/usr/bin/env bash
# Holt ein quelloffenes Android-Projekt (git clone) nach clones/<name> und zeigt Lizenz + Build-Typ.
# Das ist "klonen" im Sinne von git clone: fremde Quelltexte, die du bauen, lesen oder erweitern willst.
# Nachbauen einer App nach Beschreibung/Screenshots: siehe .claude/skills/android-app-clone.
#
# Benutzung:  scripts/clone-app.sh https://github.com/<owner>/<repo> [name]
set -euo pipefail

URL="${1:?Repo-URL fehlt. Beispiel: scripts/clone-app.sh https://github.com/owner/repo}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${2:-$(basename "${URL%.git}")}"
DEST="$ROOT/clones/$NAME"

[ ! -e "$DEST" ] || { echo "FEHLER: $DEST existiert schon." >&2; exit 1; }
mkdir -p "$ROOT/clones"
git clone --depth 1 "$URL" "$DEST"

echo
echo "== Lizenz =="
ls "$DEST" | grep -i -E '^(licen[sc]e|copying|notice)' || echo "keine Lizenzdatei gefunden -> alle Rechte beim Urheber, nur lokal ansehen/bauen, nicht weiterverbreiten"
echo
echo "== Build-Typ =="
if   [ -f "$DEST/gradlew" ]                                     ; then echo "Gradle-Wrapper:   cd clones/$NAME && ./gradlew assembleDebug"
elif ls "$DEST"/*.gradle "$DEST"/*.gradle.kts >/dev/null 2>&1   ; then echo "Gradle ohne Wrapper: gradle wrapper --gradle-version <Version> (Version aus README/CI)"
elif [ -f "$DEST/pubspec.yaml" ]                                ; then echo "Flutter-Projekt (flutter build apk) – Flutter-SDK nötig"
elif [ -f "$DEST/package.json" ]                                ; then echo "React Native / Capacitor / Web – siehe package.json und README"
else echo "unbekannt – README lesen"; fi
