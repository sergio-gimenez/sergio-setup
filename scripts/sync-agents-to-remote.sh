#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    printf 'Usage: %s <ssh-host>\n' "$(basename "$0")" >&2
    exit 1
fi

REMOTE_HOST="$1"
SOURCE_DIR="$HOME/.agents"

if [ ! -d "$SOURCE_DIR" ]; then
    printf 'Agents source directory not found: %s\n' "$SOURCE_DIR" >&2
    exit 1
fi

tar -C "$HOME" -cf - .agents | ssh "$REMOTE_HOST" \
    "tar -C \"$HOME\" -xf - && chmod 700 \"$HOME/.agents\" && find \"$HOME/.agents\" -type d -exec chmod 700 {} + && find \"$HOME/.agents\" -type f -exec chmod 600 {} +"

printf 'Copied %s to %s:%s\n' "$SOURCE_DIR" "$REMOTE_HOST" '$HOME/.agents'
