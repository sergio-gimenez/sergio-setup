#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMUX_CONF_SOURCE="$ROOT_DIR/dotfiles/.tmux.conf-remote"
TMUX_CONF_TARGET="$HOME/.tmux.conf"
TMUX_CONF_BACKUP="$HOME/.tmux.conf.backup.$(date +%Y%m%d%H%M%S)"

if [ -e "$TMUX_CONF_TARGET" ] && [ ! -L "$TMUX_CONF_TARGET" ]; then
    cp "$TMUX_CONF_TARGET" "$TMUX_CONF_BACKUP"
    printf 'Backed up existing .tmux.conf to %s\n' "$TMUX_CONF_BACKUP"
fi

cp "$TMUX_CONF_SOURCE" "$TMUX_CONF_TARGET"

printf 'Remote tmux config installed at %s\n' "$TMUX_CONF_TARGET"
