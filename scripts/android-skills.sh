#!/usr/bin/env bash
# Installiert die offiziellen Android-Skills von Google (über das `android`-CLI) in dieses Repo.
# Sie landen in .claude/skills/<name>/ (per .gitignore ausgeschlossen, werden bei Bedarf neu geholt).
#
# Benutzung:  scripts/android-skills.sh            # kuratierte Auswahl
#             ANDROID_SKILLS="all" scripts/android-skills.sh
#             scripts/android-skills.sh --list     # alle verfügbaren Skills anzeigen
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
ANDROID_CLI="$ANDROID_HOME/cmdline-tools/latest/bin/android"

[ -x "$ANDROID_CLI" ] || { echo "FEHLER: android-CLI fehlt. Zuerst scripts/android-setup.sh ausführen." >&2; exit 1; }

if [ "${1:-}" = "--list" ]; then
  exec "$ANDROID_CLI" --no-metrics skills list
fi

DEFAULT_SKILLS="android-cli ios-to-android edge-to-edge navigation-3 adaptive \
jetpack-compose-performance migrate-xml-views-to-jetpack-compose testing-setup agp-9-upgrade \
camerax r8-analyzer android-permissions-security android-intent-security play-policy-insights"
SKILLS="${ANDROID_SKILLS:-$DEFAULT_SKILLS}"

if [ "$SKILLS" = "all" ]; then
  "$ANDROID_CLI" --no-metrics skills add --all --agent=claude-code --project="$ROOT"
else
  for s in $SKILLS; do
    [ -f "$ROOT/.claude/skills/$s/SKILL.md" ] && continue   # schon da
    "$ANDROID_CLI" --no-metrics skills add --agent=claude-code --project="$ROOT" "$s"
  done
fi
echo ">> Android-Skills bereit in $ROOT/.claude/skills/"
