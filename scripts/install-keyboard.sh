#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

pkexec localectl set-x11-keymap es pc105 cat
printf 'Keyboard layout set to Spanish (Catalan ·)\n'

# Install dark-mode toggle script
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/toggle-gnome-dark-mode.sh" "$HOME/.local/bin/toggle-gnome-dark-mode.sh"
chmod +x "$HOME/.local/bin/toggle-gnome-dark-mode.sh"
printf 'Installed dark-mode toggle script to ~/.local/bin/toggle-gnome-dark-mode.sh\n'

# Add GNOME custom keybinding for dark-mode toggle
CUSTOM_BINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
CURRENT_BINDINGS=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

# Check if custom4 is already in the list
if [[ "$CURRENT_BINDINGS" != *"custom4"* ]]; then
    # Add custom4 to the list (strip trailing bracket, add entry, close bracket)
    NEW_BINDINGS=$(echo "$CURRENT_BINDINGS" | sed 's/\]$/, \x27\/org\/gnome\/settings-daemon\/plugins\/media-keys\/custom-keybindings\/custom4\/\x27]/')
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_BINDINGS"
fi

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$CUSTOM_BINDING_PATH" name "Toggle Dark Mode"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$CUSTOM_BINDING_PATH" command "$HOME/.local/bin/toggle-gnome-dark-mode.sh"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$CUSTOM_BINDING_PATH" binding "<Control><Alt><Shift>d"

printf 'Bound Super+Shift+D to toggle GNOME light/dark mode\n'
