#!/usr/bin/env bash
set -euo pipefail

SYNC_DIR="${SYNCTHING_SYNC_DIR:-$HOME/Sync}"

if ! command -v syncthing >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y syncthing
fi

mkdir -p "$SYNC_DIR"

systemctl --user enable --now syncthing.service

printf 'Syncthing is running.\n'
printf 'Sync folder: %s\n' "$SYNC_DIR"
printf 'Device ID: %s\n' "$(syncthing --device-id)"
printf 'Open http://127.0.0.1:8384 to pair this machine with your phone.\n'
