#!/usr/bin/env bash
# Install claude-switch by symlinking it into a directory on your PATH.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/bin/claude-switch"
chmod +x "$SRC"

# Pick a writable destination on the PATH.
for d in "$HOME/.local/bin" "/usr/local/bin" "/opt/homebrew/bin"; do
  if [ -d "$d" ] && [ -w "$d" ]; then DEST="$d/claude-switch"; break; fi
done
: "${DEST:=$HOME/.local/bin/claude-switch}"
mkdir -p "$(dirname "$DEST")"

ln -sf "$SRC" "$DEST"
echo "✓ Installed: $DEST -> $SRC"

case ":$PATH:" in
  *":$(dirname "$DEST"):"*) ;;
  *) echo "! Add to your PATH:  export PATH=\"$(dirname "$DEST"):\$PATH\"" ;;
esac
echo "Try:  claude-switch help"
