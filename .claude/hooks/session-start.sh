#!/bin/bash
# SessionStart-Hook: macht jede Claude-Code-Cloud-Session Android-fähig.
#  1. Android SDK (cmdline-tools, platform-tools, Plattform, build-tools)
#  2. Offizielle Android-Skills von Google (kuratierte Auswahl)
#  3. Craft Anything CLI (gepinnte Version, Prüfsumme wird verifiziert)
#  4. Umgebungsvariablen für die Session
# Läuft nur in der Cloud ($CLAUDE_CODE_REMOTE), synchron, und überspringt fertige Installationen.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}"

if [ -z "${ANDROID_HOME:-}" ]; then
  if [ "$(id -u)" = "0" ] || [ -w /opt ]; then ANDROID_HOME=/opt/android-sdk; else ANDROID_HOME="$HOME/android-sdk"; fi
fi
export ANDROID_HOME ANDROID_SDK_ROOT="$ANDROID_HOME"

# 1) Android SDK – nur erneut ausführen, wenn Skript oder Hook sich geändert haben
hashes="$ANDROID_HOME/.session-start.sha256"
if ! sha256sum --check --status "$hashes" 2>/dev/null; then
  rm -f "$hashes"
  scripts/android-setup.sh
  sha256sum .claude/hooks/session-start.sh scripts/android-setup.sh > "$hashes"
fi

# 2) Offizielle Android-Skills (idempotent: vorhandene werden übersprungen)
scripts/android-skills.sh

# 3) Craft Anything CLI (idempotent: gleiche Version = nichts zu tun)
scripts/install-craft-anything.sh

# 4) Für jede Session nötig: Umgebung setzen
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo "export ANDROID_HOME=\"$ANDROID_HOME\""
    echo "export ANDROID_SDK_ROOT=\"$ANDROID_HOME\""
    echo "export PATH=\"\$HOME/.local/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:\$PATH\""
  } >> "$CLAUDE_ENV_FILE"
fi
