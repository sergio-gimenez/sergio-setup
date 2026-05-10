#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

# ── Window Manager keybindings ───────────────────────────────────────────────

WM_SCHEMA="org.gnome.desktop.wm.keybindings"

# Custom overrides matching the source machine
gsettings set "$WM_SCHEMA" close "['<Super>w']"
gsettings set "$WM_SCHEMA" maximize "['<Shift><Control>m']"
gsettings set "$WM_SCHEMA" minimize "['<Super>h']"
gsettings set "$WM_SCHEMA" switch-windows "['<Alt>Tab']"
gsettings set "$WM_SCHEMA" switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set "$WM_SCHEMA" switch-applications "@as []"
gsettings set "$WM_SCHEMA" switch-applications-backward "@as []"
gsettings set "$WM_SCHEMA" move-to-workspace-left "['<Shift><Control><Super>Left']"
gsettings set "$WM_SCHEMA" move-to-workspace-right "['<Shift><Control><Super>Right']"
gsettings set "$WM_SCHEMA" switch-to-workspace-left "['<Shift><Super>Tab']"
gsettings set "$WM_SCHEMA" switch-to-workspace-right "['<Super>Tab']"

printf 'Synced WM keybindings.\n'

# ── Custom media keybindings ─────────────────────────────────────────────────

# Rebuild custom list from scratch to match source exactly
CUSTOM_LIST="['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "$CUSTOM_LIST"

# custom0: Terminal
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Terminal'"
if command -v ghostty >/dev/null 2>&1; then
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'ghostty'"
elif command -v gnome-terminal >/dev/null 2>&1; then
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'gnome-terminal'"
else
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'kgx'"
fi
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Control><Alt>t'"

# custom1: Flameshot screenshot
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/name "'Fameshot'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/command "'sh -c -- \"QT_QPA_PLATFORM=wayland flameshot gui --clipboard --path \$HOME/Pictures/Screenshots\"'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/binding "'<Shift><Control>Home'"

# custom2: File Explorer
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/name "'File Explorer'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/command "'nautilus'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/binding "'<Super>e'"

# custom3: Gpaste
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/name "'Gpaste'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/command "'/usr/libexec/gpaste/gpaste-ui'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/binding "'<Super>c'"

# custom4: Toggle Dark Mode
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/name "'Toggle Dark Mode'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/command "'\$HOME/.local/bin/toggle-gnome-dark-mode.sh'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/binding "'<Control><Alt><Shift>d'"

printf 'Synced custom media keybindings.\n'

# ── Disable default Print Screen so custom1/custom4 work cleanly ─────────────

dconf write /org/gnome/settings-daemon/plugins/media-keys/screenshot "''"

printf 'GNOME keybindings synced. Log out and back in for full effect.\n'
