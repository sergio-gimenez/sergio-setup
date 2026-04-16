#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SOURCE="$ROOT_DIR/keyd/default.conf"
CONFIG_TARGET="/etc/keyd/default.conf"

if ! command -v keyd.rvaiya >/dev/null 2>&1; then
    pkexec apt install -y keyd
fi

pkexec mkdir -p /etc/keyd
pkexec cp "$CONFIG_SOURCE" "$CONFIG_TARGET"
pkexec systemctl enable --now keyd
pkexec keyd.rvaiya reload

printf 'Installed keyd config to %s\n' "$CONFIG_TARGET"
