#!/usr/bin/env bash
set -euo pipefail

# Tactile: keyboard window tiling on a grid (Super+T, then two tiles).
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UUID="tactile@lundal.io"

if ! command -v gnome-shell >/dev/null 2>&1; then
    printf 'Skipped Tactile. GNOME Shell not installed.\n'
    exit 0
fi

SHELL_MAJOR="$(gnome-shell --version | grep -oE '[0-9]+' | head -1)"
INFO="$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=$UUID&shell_version=$SHELL_MAJOR")"
DOWNLOAD_PATH="$(printf '%s' "$INFO" | grep -oE '"download_url": *"[^"]+"' | sed -E 's/.*"(\/[^"]+)"/\1/')"

if [ -z "$DOWNLOAD_PATH" ]; then
    printf 'Skipped Tactile. No release for GNOME Shell %s.\n' "$SHELL_MAJOR" >&2
    exit 0
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
curl -fsSL "https://extensions.gnome.org$DOWNLOAD_PATH" -o "$TMP_DIR/tactile.zip"
gnome-extensions install --force "$TMP_DIR/tactile.zip"

# The running shell only notices new extensions after a re-login on Wayland, so
# enable it in the settings list instead of via `gnome-extensions enable`.
enabled="$(gsettings get org.gnome.shell enabled-extensions)"
if [[ "$enabled" != *"$UUID"* ]]; then
    if [ "$enabled" = "@as []" ] || [ "$enabled" = "[]" ]; then
        gsettings set org.gnome.shell enabled-extensions "['$UUID']"
    else
        gsettings set org.gnome.shell enabled-extensions "${enabled%]}, '$UUID']"
    fi
fi

dconf load /org/gnome/shell/extensions/tactile/ < "$ROOT_DIR/dotfiles/tactile/tactile.dconf"

printf 'Tactile installed and enabled. Log out and back in to load it.\n'
