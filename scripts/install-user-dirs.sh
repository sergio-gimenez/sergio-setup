#!/usr/bin/env bash
set -euo pipefail

LOCALE_FILE="$HOME/.config/user-dirs.locale"

mkdir -p "$(dirname "$LOCALE_FILE")"

echo "en_GB" > "$LOCALE_FILE"
LANG=en_GB.utf8 LANGUAGE=en_GB:en xdg-user-dirs-update --force

printf 'User directories set to English.\n'
