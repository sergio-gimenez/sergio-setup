#!/usr/bin/env bash
set -euo pipefail

if ! command -v flameshot >/dev/null 2>&1; then
    sudo apt install -y flameshot
fi

# Disable GNOME default "Save a screenshot to Pictures" shortcut
dconf write /org/gnome/settings-daemon/plugins/media-keys/screenshot "''"

FLAMESHOT_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4"

if ! dconf dump "$FLAMESHOT_PATH/" 2>/dev/null | grep -q 'Flameshot'; then
    dconf write "$FLAMESHOT_PATH/name" "'Flameshot'"
    dconf write "$FLAMESHOT_PATH/command" "'/usr/bin/flameshot gui'"
    dconf write "$FLAMESHOT_PATH/binding" "'<Print>'"

    # Ensure custom4 is registered in the keybindings list
    CURRENT_LIST=$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings 2>/dev/null || true)
    if [[ -z "$CURRENT_LIST" ]] || [[ "$CURRENT_LIST" == "@as []" ]]; then
        dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['custom4/']"
    elif [[ "$CURRENT_LIST" != *"custom4/"* ]]; then
        NEW_LIST="${CURRENT_LIST%]}, 'custom4/']"
        dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "$NEW_LIST"
    fi
fi

printf 'Installed flameshot with Print Screen keybinding.\n'
