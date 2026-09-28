#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$ROOT_DIR/flatpaks.txt"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

run_as_root apt-get install -y flatpak gnome-software-plugin-flatpak
run_as_root flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

mapfile -t apps < <(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$LIST" | grep -v '^$')
if [ "${#apps[@]}" -gt 0 ]; then
    run_as_root flatpak install -y --noninteractive flathub "${apps[@]}"
fi

printf 'Installed %s flatpaks from %s\n' "${#apps[@]}" "$LIST"
