#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf '=== Remote Minimal Dev Server Setup ===\n\n'

"$ROOT_DIR/install-headless.sh"

if command -v syncthing >/dev/null 2>&1; then
    printf '[*] Syncthing already installed\n'
else
    printf '[*] You can install syncthing later with: sudo apt install syncthing\n'
fi

if ! command -v tailscale >/dev/null 2>&1; then
    printf '\n[!] Tailscale not found. Install it for easy remote access:\n'
    printf '    curl -fsSL https://tailscale.com/install.sh | sh\n'
    printf '    sudo tailscale up\n'
fi

printf '\n=== Remote setup complete ===\n'
printf 'Next steps:\n'
printf '  1. Log out and back in (or run: exec zsh)\n'
printf '  2. Run opencode and connect provider if needed\n'
printf '  3. Open nvim to let LazyVim install plugins\n'
printf '  4. Connect from tablet: mosh user@your-server-ip -- tmux new -A -s main\n'
