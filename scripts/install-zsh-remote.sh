#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC_SOURCE="$ROOT_DIR/dotfiles/.zshrc-remote"
ZSHRC_TARGET="$HOME/.zshrc"
ZSHRC_BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"

if [ -e "$ZSHRC_TARGET" ] && [ ! -L "$ZSHRC_TARGET" ] && ! cmp -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"; then
    cp "$ZSHRC_TARGET" "$ZSHRC_BACKUP"
    printf 'Backed up existing .zshrc to %s\n' "$ZSHRC_BACKUP"
fi

if [ ! -e "$ZSHRC_TARGET" ] || [ -L "$ZSHRC_TARGET" ] || ! cmp -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"; then
    cp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
fi

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7 2>/dev/null || true)"
TARGET_SHELL="$(command -v zsh)"

if [ "$CURRENT_SHELL" != "$TARGET_SHELL" ]; then
    if [ -t 0 ]; then
        chsh -s "$TARGET_SHELL"
        printf 'Default shell changed to zsh. Log out and back in for changes to take effect.\n'
    else
        printf 'Skipping default shell change in non-interactive session. Run: chsh -s %s\n' "$TARGET_SHELL"
    fi
fi

printf 'Remote zsh config installed.\n'
