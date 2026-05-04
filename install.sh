#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$ROOT_DIR/scripts/install-keyd.sh"
"$ROOT_DIR/scripts/install-keyboard.sh"
"$ROOT_DIR/scripts/install-user-dirs.sh"
"$ROOT_DIR/scripts/install-lazyvim.sh"
"$ROOT_DIR/scripts/install-gpaste.sh"
"$ROOT_DIR/scripts/install-flameshot.sh"
"$ROOT_DIR/scripts/install-zsh.sh"
"$ROOT_DIR/scripts/install-ghostty.sh"
"$ROOT_DIR/scripts/install-tmux.sh"
"$ROOT_DIR/scripts/install-k9s.sh"
"$ROOT_DIR/scripts/install-syncthing.sh"
"$ROOT_DIR/scripts/install-logseq.sh"
"$ROOT_DIR/scripts/install-caveman.sh"
"$ROOT_DIR/scripts/install-ghostty-config.sh"
"$ROOT_DIR/scripts/fix-displaylink.sh"

printf 'Setup complete.\n'
