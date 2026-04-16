#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/sergio-gimenez/lazyvim-config"
TARGET_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
ALT_REPO_URL="git@github.com:sergio-gimenez/lazyvim-config.git"

if ! command -v git >/dev/null 2>&1; then
    pkexec apt install -y git
fi

if ! command -v nvim >/dev/null 2>&1; then
    pkexec apt install -y neovim
fi

mkdir -p "$HOME/.config"

if [ -e "$TARGET_DIR" ] && [ ! -d "$TARGET_DIR/.git" ] && [ ! -L "$TARGET_DIR" ]; then
    mv "$TARGET_DIR" "$BACKUP_DIR"
    printf 'Moved existing nvim config to %s\n' "$BACKUP_DIR"
fi

if [ -d "$TARGET_DIR/.git" ]; then
    CURRENT_REMOTE="$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)"

    if [ "$CURRENT_REMOTE" = "$REPO_URL" ] || [ "$CURRENT_REMOTE" = "$ALT_REPO_URL" ]; then
        git -C "$TARGET_DIR" pull --ff-only
    else
        mv "$TARGET_DIR" "$BACKUP_DIR"
        printf 'Moved existing git-based nvim config to %s\n' "$BACKUP_DIR"
        git clone "$REPO_URL" "$TARGET_DIR"
    fi
else
    rm -rf "$TARGET_DIR"
    git clone "$REPO_URL" "$TARGET_DIR"
fi

printf 'LazyVim config installed in %s\n' "$TARGET_DIR"
