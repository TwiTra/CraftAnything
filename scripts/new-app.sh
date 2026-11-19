#!/usr/bin/env bash
# Legt eine neue Android-App (Kotlin + Jetpack Compose + Navigation 3) unter apps/<ordner> an.
# Nutzt die offizielle Google-Vorlage `empty-activity` des android-CLI (AGP 9, Gradle-Wrapper inklusive).
#
# Benutzung:  scripts/new-app.sh "Notiz Block" de.twitra.notizblock
#             scripts/new-app.sh "Notiz Block" de.twitra.notizblock 26    # minSdk (Standard: 26)
set -euo pipefail

NAME="${1:?Name fehlt. Beispiel: scripts/new-app.sh \"Notiz Block\" de.twitra.notizblock}"
APP_ID="${2:?Application-ID fehlt. Beispiel: de.twitra.notizblock}"
MIN_SDK="${3:-26}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
ANDROID_CLI="$ANDROID_HOME/cmdline-tools/latest/bin/android"
[ -x "$ANDROID_CLI" ] || { echo "FEHLER: android-CLI fehlt. Zuerst scripts/android-setup.sh ausführen." >&2; exit 1; }

# Ordnername: Kleinbuchstaben, nur a-z0-9 und Bindestrich
SLUG="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]' | sed -e 's/ä/ae/g;s/ö/oe/g;s/ü/ue/g;s/ß/ss/g' | tr -c 'a-z0-9\n' '-' | sed -e 's/--*/-/g;s/^-//;s/-$//')"
OUT="$ROOT/apps/$SLUG"
[ ! -e "$OUT" ] || { echo "FEHLER: $OUT existiert schon." >&2; exit 1; }

"$ANDROID_CLI" --no-metrics create empty-activity \
  --name="$NAME" --application-id="$APP_ID" --namespace="$APP_ID" --min-sdk="$MIN_SDK" -o "$OUT"

rm -f "$OUT/local.properties"          # maschinenspezifisch, nicht einchecken
echo ">> App angelegt: apps/$SLUG"
echo "   Bauen:   cd apps/$SLUG && ./gradlew assembleDebug"
echo "   Tests:   cd apps/$SLUG && ./gradlew testDebugUnitTest lintDebug"
