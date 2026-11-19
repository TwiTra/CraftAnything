#!/usr/bin/env bash
# Installiert das Craft-Anything-CLI (https://github.com/storytold/craft-anything, Apache-2.0)
# aus dem offiziellen GitHub-Release. Version und SHA-256-Prüfsumme sind festgelegt (gepinnt);
# bei Abweichung bricht das Skript ab. Es wird nur `craft-anything-cli` entpackt (keine GUI).
#
# Benutzung:  scripts/install-craft-anything.sh
# Ergebnis:   ~/.local/bin/craft-anything-cli
#
# Neue Version übernehmen: VERSION und SHA256 unten ändern. Die Prüfsumme steht im Release unter
# SHA256SUMS.txt (Zeile "craft-anything-<version>-linux-x86_64.tar.gz").
set -euo pipefail

VERSION="0.6.1"                 # Tag v0.6.1 = Commit 48a9c5a60ff83ff620f98661339be6281a7debc6
SHA256="83ec0730c9117f399122b315c63ed4c3a8d31ac55bddd74cb8b33cd2f76ef704"

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) ASSET="craft-anything-${VERSION}-linux-x86_64.tar.gz" ;;
  *)
    echo "Dieses Skript kennt nur Linux x86_64. Andere Systeme: https://github.com/storytold/craft-anything/releases/tag/v${VERSION}" >&2
    exit 1 ;;
esac

DEST="${CRAFT_ANYTHING_HOME:-$HOME/.local/share/craft-anything}/${VERSION}"
BIN_DIR="${CRAFT_ANYTHING_BIN:-$HOME/.local/bin}"

if [ -x "$DEST/craft-anything-cli" ]; then
  echo ">> craft-anything-cli ${VERSION} ist bereits installiert ($DEST)."
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo ">> Lade ${ASSET} ..."
  curl -fsSL --retry 4 --retry-delay 3 -o "$tmp/release.tar.gz" \
    "https://github.com/storytold/craft-anything/releases/download/v${VERSION}/${ASSET}"
  echo "${SHA256}  $tmp/release.tar.gz" | sha256sum -c - >/dev/null \
    || { echo "FEHLER: Prüfsumme stimmt nicht. Es wird nichts installiert." >&2; exit 1; }
  # Nur das CLI und die Lizenz entpacken, in ein neues leeres Verzeichnis.
  mkdir -p "$tmp/x" "$DEST"
  tar -xzf "$tmp/release.tar.gz" -C "$tmp/x" --strip-components=1 \
    "craft-anything-${VERSION}-linux-x86_64/bin/craft-anything-cli" \
    "craft-anything-${VERSION}-linux-x86_64/share/doc/craft-anything/LICENSE-MIT"
  install -m 0755 "$tmp/x/bin/craft-anything-cli" "$DEST/craft-anything-cli"
  cp "$tmp/x/share/doc/craft-anything/LICENSE-MIT" "$DEST/" 2>/dev/null || true
fi

mkdir -p "$BIN_DIR"
ln -sfn "$DEST/craft-anything-cli" "$BIN_DIR/craft-anything-cli"
echo ">> Fertig: $BIN_DIR/craft-anything-cli -> $DEST/craft-anything-cli"
case ":$PATH:" in *":$BIN_DIR:"*) ;; *) echo "   Hinweis: $BIN_DIR ist nicht im PATH." ;; esac
