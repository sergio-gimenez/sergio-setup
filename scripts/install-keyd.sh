#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SOURCE="$ROOT_DIR/keyd/default.conf"
CONFIG_TARGET="/etc/keyd/default.conf"

# Prefer pkexec in local desktop sessions. Fall back to sudo for SSH/headless runs.
source "$ROOT_DIR/scripts/lib/run-as-root.sh"

if ! command -v keyd.rvaiya >/dev/null 2>&1; then
    run_as_root apt install -y keyd
fi

run_as_root mkdir -p /etc/keyd
run_as_root cp "$CONFIG_SOURCE" "$CONFIG_TARGET"
run_as_root systemctl enable --now keyd
run_as_root keyd.rvaiya reload

if getent group keyd >/dev/null 2>&1 && ! id -nG "$USER" | grep -qw keyd; then
    run_as_root usermod -aG keyd "$USER"
    printf 'Added %s to keyd group. Log out and back in for full access.\n' "$USER"
fi

printf 'Installed keyd config to %s\n' "$CONFIG_TARGET"
