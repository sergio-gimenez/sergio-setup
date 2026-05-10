#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    printf 'Usage: %s <ssh-host>\n' "$(basename "$0")" >&2
    exit 1
fi

REMOTE_HOST="$1"
SOURCE_DIR="$HOME/.ssh"

if [ ! -d "$SOURCE_DIR" ]; then
    printf 'SSH source directory not found: %s\n' "$SOURCE_DIR" >&2
    exit 1
fi

tar -C "$HOME" -cf - .ssh | ssh "$REMOTE_HOST" \
    "tar -C \"$HOME\" -xf - && chmod 700 \"$HOME/.ssh\" && find \"$HOME/.ssh\" -type d -exec chmod 700 {} + && find \"$HOME/.ssh\" -type f -exec chmod 600 {} +"

printf 'Copied %s to %s:%s\n' "$SOURCE_DIR" "$REMOTE_HOST" '$HOME/.ssh'
