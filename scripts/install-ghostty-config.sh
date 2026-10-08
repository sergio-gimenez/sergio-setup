#!/usr/bin/env bash
# Install Ghostty config
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$HOME/.config/ghostty/themes"
cp "$ROOT_DIR/dotfiles/ghostty/config" "$HOME/.config/ghostty/config"
# tokyonight moon/day exactly as Neovim draws them (copied from tokyonight.nvim extras/ghostty)
cp "$ROOT_DIR"/dotfiles/ghostty/themes/* "$HOME/.config/ghostty/themes/"

printf 'Ghostty config installed in ~/.config/ghostty/config\n'