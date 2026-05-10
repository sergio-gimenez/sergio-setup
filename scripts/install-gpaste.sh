#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/run-as-root.sh"

if ! dpkg -l | grep -q gpaste-2; then
    run_as_root apt install -y gpaste-2
fi

GPASTE_KEYBINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3"

if ! dconf dump "$GPASTE_KEYBINDING_PATH/" 2>/dev/null | grep -q 'Gpaste'; then
    CURRENT_LIST=$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings 2>/dev/null || true)
    if [[ -z "$CURRENT_LIST" ]] || [[ "$CURRENT_LIST" == "@as []" ]]; then
        dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['custom3/']"
    elif [[ "$CURRENT_LIST" != *"custom3/"* ]]; then
        NEW_LIST="${CURRENT_LIST%]}, 'custom3/']"
        dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "$NEW_LIST"
    fi

    dconf write "$GPASTE_KEYBINDING_PATH/name" "'Gpaste'"
    dconf write "$GPASTE_KEYBINDING_PATH/command" "'/usr/libexec/gpaste/gpaste-ui'"
    dconf write "$GPASTE_KEYBINDING_PATH/binding" "'<Super>c'"
fi

printf 'Installed gpaste-2 with Super+C keybinding.\n'
