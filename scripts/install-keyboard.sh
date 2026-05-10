#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Prefer pkexec in local desktop sessions. Fall back to sudo for SSH/headless runs.
source "$ROOT_DIR/scripts/lib/run-as-root.sh"

if localectl status 2>/dev/null | grep -Fq 'X11 Layout: es' \
    && localectl status 2>/dev/null | grep -Fq 'X11 Model: pc105' \
    && localectl status 2>/dev/null | grep -Fq 'X11 Variant: cat'; then
    printf 'Keyboard layout already set to Spanish (Catalan ·)\n'
else
    run_as_root localectl set-x11-keymap es pc105 cat
    printf 'Keyboard layout set to Spanish (Catalan ·)\n'
fi

# Install dark-mode toggle script
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/toggle-gnome-dark-mode.sh" "$HOME/.local/bin/toggle-gnome-dark-mode.sh"
chmod +x "$HOME/.local/bin/toggle-gnome-dark-mode.sh"
printf 'Installed dark-mode toggle script to ~/.local/bin/toggle-gnome-dark-mode.sh\n'

# Add GNOME custom keybinding for dark-mode toggle
CUSTOM_BINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5"
CURRENT_BINDINGS=$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings 2>/dev/null || true)

if [[ -z "$CURRENT_BINDINGS" ]] || [[ "$CURRENT_BINDINGS" == "@as []" ]]; then
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['custom5/']"
elif [[ "$CURRENT_BINDINGS" != *"custom5/"* ]]; then
    NEW_BINDINGS="${CURRENT_BINDINGS%]}, 'custom5/']"
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "$NEW_BINDINGS"
fi

dconf write "$CUSTOM_BINDING_PATH/name" "'Toggle Dark Mode'"
dconf write "$CUSTOM_BINDING_PATH/command" "'$HOME/.local/bin/toggle-gnome-dark-mode.sh'"
dconf write "$CUSTOM_BINDING_PATH/binding" "'<Control><Alt><Shift>d'"

printf 'Bound Super+Shift+D to toggle GNOME light/dark mode\n'
