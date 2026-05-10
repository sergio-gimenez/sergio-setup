#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

# Find a terminal emulator — prefer ghostty since install-ghostty.sh builds to ~/.local
if [ -x "$HOME/.local/bin/ghostty" ]; then
    TERMINAL_CMD="$HOME/.local/bin/ghostty"
elif command -v ghostty >/dev/null 2>&1; then
    TERMINAL_CMD="$(command -v ghostty)"
elif command -v gnome-terminal >/dev/null 2>&1; then
    TERMINAL_CMD="/usr/bin/gnome-terminal"
elif command -v kgx >/dev/null 2>&1; then
    TERMINAL_CMD="/usr/bin/kgx"
else
    printf 'No supported terminal emulator found. Skipping terminal shortcut.\n' >&2
    exit 0
fi

CUSTOM_BINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0"
CURRENT_BINDINGS=$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings 2>/dev/null || true)

if [[ -z "$CURRENT_BINDINGS" ]] || [[ "$CURRENT_BINDINGS" == "@as []" ]]; then
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['custom0/']"
elif [[ "$CURRENT_BINDINGS" != *"custom0/"* ]]; then
    NEW_BINDINGS="${CURRENT_BINDINGS%]}, 'custom0/']"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "$NEW_BINDINGS"
fi

dconf write "$CUSTOM_BINDING_PATH/name" "'Open Terminal'"
dconf write "$CUSTOM_BINDING_PATH/command" "'$TERMINAL_CMD'"
dconf write "$CUSTOM_BINDING_PATH/binding" "'<Control><Alt>t'"

printf 'Bound Ctrl+Alt+T to %s\n' "$TERMINAL_CMD"
