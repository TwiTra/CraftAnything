#!/usr/bin/env bash
# Installiert das Android SDK (nur Kommandozeilen-Tools, kein Android Studio).
# Idempotent: bereits installierte Pakete werden übersprungen.
#
# Benutzung:   scripts/android-setup.sh
# Optional:    ANDROID_HOME=/pfad  ANDROID_PLATFORM=36  ANDROID_BUILD_TOOLS=36.0.0
set -euo pipefail

CMDLINE_TOOLS_BUILD="${CMDLINE_TOOLS_BUILD:-16111833}"
# Die offizielle Projektvorlage (android create empty-activity) nutzt compileSdk 37.
ANDROID_PLATFORM="${ANDROID_PLATFORM:-37.0}"
ANDROID_BUILD_TOOLS="${ANDROID_BUILD_TOOLS:-36.0.0}"

if [ -z "${ANDROID_HOME:-}" ]; then
  if [ -w /opt ] || [ "$(id -u)" = "0" ]; then ANDROID_HOME=/opt/android-sdk; else ANDROID_HOME="$HOME/android-sdk"; fi
fi
export ANDROID_HOME ANDROID_SDK_ROOT="$ANDROID_HOME"
SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"

if ! command -v java >/dev/null 2>&1; then
  echo "FEHLER: Java (JDK 17+) fehlt. Unter Debian/Ubuntu: apt-get install -y openjdk-21-jdk-headless" >&2
  exit 1
fi

# 1) Kommandozeilen-Tools holen
if [ ! -x "$SDKMANAGER" ]; then
  echo ">> Lade Android cmdline-tools ($CMDLINE_TOOLS_BUILD) ..."
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL --retry 4 --retry-delay 3 -o "$tmp/cmdline-tools.zip" \
    "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_BUILD}_latest.zip"
  unzip -q "$tmp/cmdline-tools.zip" -d "$tmp"
  mkdir -p "$ANDROID_HOME/cmdline-tools"
  rm -rf "$ANDROID_HOME/cmdline-tools/latest"
  mv "$tmp/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
fi

# 2) Lizenzen akzeptieren (yes beendet sich per SIGPIPE -> pipefail kurz aus)
mkdir -p "$ANDROID_HOME/licenses"
set +o pipefail
yes 2>/dev/null | "$SDKMANAGER" --sdk_root="$ANDROID_HOME" --licenses >/dev/null 2>&1 || true
set -o pipefail

# 3) Pakete installieren, falls noch nicht vorhanden
wanted=()
[ -d "$ANDROID_HOME/platform-tools" ]                         || wanted+=("platform-tools")
[ -d "$ANDROID_HOME/platforms/android-${ANDROID_PLATFORM}" ]   || wanted+=("platforms;android-${ANDROID_PLATFORM}")
[ -d "$ANDROID_HOME/build-tools/${ANDROID_BUILD_TOOLS}" ]      || wanted+=("build-tools;${ANDROID_BUILD_TOOLS}")

if [ "${#wanted[@]}" -gt 0 ]; then
  echo ">> Installiere: ${wanted[*]}"
  set +o pipefail
  yes 2>/dev/null | "$SDKMANAGER" --sdk_root="$ANDROID_HOME" "${wanted[@]}"
  rc=${PIPESTATUS[1]}
  set -o pipefail
  [ "$rc" = "0" ] || { echo "FEHLER: sdkmanager ist mit Code $rc beendet." >&2; exit "$rc"; }
else
  echo ">> Android SDK ist bereits vollständig ($ANDROID_HOME)."
fi

echo ">> Fertig. ANDROID_HOME=$ANDROID_HOME"
