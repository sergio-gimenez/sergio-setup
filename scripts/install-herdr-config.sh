#!/usr/bin/env bash
# Install herdr config (herdr itself is installed separately)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$HOME/.config/herdr"
cp "$ROOT_DIR/dotfiles/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# A running server keeps the old config until told to reload. Keybindings and theme
# live in the attached client, which this does not reach: press prefix+R there.
if command -v herdr >/dev/null 2>&1; then
    herdr server reload-config >/dev/null 2>&1 || true
fi

printf 'herdr config installed in ~/.config/herdr/config.toml\n'
