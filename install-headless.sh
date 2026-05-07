#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${HEADLESS_USER:-$(stat -c '%U' "$ROOT_DIR")}" 

"$ROOT_DIR/scripts/install-headless-packages.sh"

if [ "$(id -u)" -eq 0 ] && [ "$TARGET_USER" != "root" ]; then
    runuser -u "$TARGET_USER" -- bash -lc "'$ROOT_DIR/scripts/install-zsh-remote.sh' && '$ROOT_DIR/scripts/install-lazyvim.sh' && '$ROOT_DIR/scripts/install-tmux-remote.sh' && '$ROOT_DIR/scripts/install-opencode.sh'"
else
    "$ROOT_DIR/scripts/install-zsh-remote.sh"
    "$ROOT_DIR/scripts/install-lazyvim.sh"
    "$ROOT_DIR/scripts/install-tmux-remote.sh"
    "$ROOT_DIR/scripts/install-opencode.sh"
fi

printf 'Headless setup complete.\n'
