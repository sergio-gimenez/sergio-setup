#!/usr/bin/env bash
# Install Ghostty config
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$HOME/.config/ghostty"
cp "$ROOT_DIR/dotfiles/ghostty/config" "$HOME/.config/ghostty/config"

printf 'Ghostty config installed in ~/.config/ghostty/config\n'