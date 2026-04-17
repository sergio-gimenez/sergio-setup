#!/usr/bin/env bash
set -euo pipefail

if ! dpkg -l | grep -q gpaste-2; then
    sudo apt install -y gpaste-2
fi

GPASTE_KEYBINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3"

if ! dconf dump "$GPaste_KEYBINDING_PATH/" 2>/dev/null | grep -q 'Gpaste'; then
    dconf write "$GPaste_KEYBINDING_PATH/name" "'Gpaste'"
    dconf write "$GPaste_KEYBINDING_PATH/command" "'/usr/libexec/gpaste/gpaste-ui'"
    dconf write "$GPaste_KEYBINDING_PATH/binding" "'<Super>c'"
fi

printf 'Installed gpaste-2 with Super+C keybinding.\n'