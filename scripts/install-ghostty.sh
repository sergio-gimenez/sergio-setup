#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/ghostty-org/ghostty"
TARGET_DIR="$HOME/.local/src/ghostty"

if [ -d "$TARGET_DIR/.git" ]; then
    git -C "$TARGET_DIR" pull --ff-only
else
    mkdir -p "$(dirname "$TARGET_DIR")"
    git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"
zig build release -Drelease-safe=true -Dcpu=baseline

mkdir -p "$HOME/.local/bin"
ln -sf "$TARGET_DIR/zig-out/bin/ghostty" "$HOME/.local/bin/ghostty"

printf 'Ghostty installed in %s\n' "$TARGET_DIR"