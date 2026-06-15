#!/usr/bin/env bash
#
# Install claude-switch.
#
# Two modes, auto-detected:
#   1. Remote  — piped straight from the internet, no clone needed:
#        curl -fsSL https://raw.githubusercontent.com/pippolino/claude-switch/main/install.sh | bash
#      Downloads the latest `claude-switch` into a PATH dir.
#   2. Local   — run from a cloned/downloaded repo (./install.sh):
#      Symlinks bin/claude-switch so edits take effect immediately.
#
# Overridable:
#   PREFIX=/usr/local/bin   ./install.sh    # force the install directory
#   CLAUDE_SWITCH_REF=main  ...             # branch/tag to fetch in remote mode
set -euo pipefail

REPO="pippolino/claude-switch"
REF="${CLAUDE_SWITCH_REF:-main}"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$REF"

# --- pick a writable destination directory on PATH ---------------------------
choose_dir() {
  if [ -n "${PREFIX:-}" ]; then printf '%s' "$PREFIX"; return; fi
  for d in "$HOME/.local/bin" "/usr/local/bin" "/opt/homebrew/bin"; do
    if [ -d "$d" ] && [ -w "$d" ]; then printf '%s' "$d"; return; fi
  done
  printf '%s' "$HOME/.local/bin"
}
DIR="$(choose_dir)"
DEST="$DIR/claude-switch"
mkdir -p "$DIR"

# --- locate a local copy (local mode) ----------------------------------------
# When piped via `curl | bash` this resolves to the cwd and the file won't be
# there, so we fall through to remote download.
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
LOCAL_SRC="$SELF_DIR/bin/claude-switch"

if [ -n "$SELF_DIR" ] && [ -f "$LOCAL_SRC" ]; then
  # Local mode: symlink so the installed command tracks your working copy.
  chmod +x "$LOCAL_SRC"
  ln -sf "$LOCAL_SRC" "$DEST"
  echo "✓ Installed (symlink): $DEST -> $LOCAL_SRC"
else
  # Remote mode: download the script.
  command -v curl >/dev/null 2>&1 || { echo "✗ curl is required" >&2; exit 1; }
  echo "Downloading claude-switch ($REF)…"
  tmp="$(mktemp)"
  curl -fsSL "$RAW_BASE/bin/claude-switch" -o "$tmp"
  # Sanity check: must look like our script.
  head -1 "$tmp" | grep -q '^#!/usr/bin/env bash' || { echo "✗ unexpected download" >&2; rm -f "$tmp"; exit 1; }
  chmod +x "$tmp"
  mv "$tmp" "$DEST"
  echo "✓ Installed: $DEST"
fi

# --- PATH hint ----------------------------------------------------------------
case ":$PATH:" in
  *":$DIR:"*) ;;
  *) echo "! $DIR is not on your PATH. Add it, e.g.:"
     echo "    echo 'export PATH=\"$DIR:\$PATH\"' >> ~/.zshrc && source ~/.zshrc" ;;
esac
echo "Try:  claude-switch help"
