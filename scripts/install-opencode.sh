#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="${XDG_BIN_DIR:-$HOME/.local/bin}"
FALLBACK_DIR="$HOME/.opencode/bin"
OPENCODE_CONFIG_DIR="$HOME/.config/opencode"

mkdir -p "$INSTALL_DIR"

if [ ! -x "$INSTALL_DIR/opencode" ] && [ ! -x "$FALLBACK_DIR/opencode" ]; then
    env OPENCODE_INSTALL_DIR="$INSTALL_DIR" XDG_BIN_DIR="$INSTALL_DIR" bash -c "$(curl -fsSL https://opencode.ai/install)"
fi

mkdir -p "$OPENCODE_CONFIG_DIR/plugins"
cp "$ROOT_DIR/dotfiles/opencode/opencode.json" "$OPENCODE_CONFIG_DIR/"
cp "$ROOT_DIR/dotfiles/opencode/opencode-notifier.json" "$OPENCODE_CONFIG_DIR/"
cp "$ROOT_DIR/dotfiles/opencode/AGENTS.md" "$OPENCODE_CONFIG_DIR/"
cp "$ROOT_DIR/dotfiles/opencode/plugins/notifications.js" "$OPENCODE_CONFIG_DIR/plugins/"

if [ -x "$INSTALL_DIR/opencode" ]; then
    printf 'OpenCode installed. Binary dir: %s\n' "$INSTALL_DIR"
elif [ -x "$FALLBACK_DIR/opencode" ]; then
    printf 'OpenCode installed. Binary dir: %s\n' "$FALLBACK_DIR"
else
    printf 'OpenCode install finished. Binary path not auto-detected.\n'
fi
