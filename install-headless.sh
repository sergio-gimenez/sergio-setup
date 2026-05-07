#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$ROOT_DIR/scripts/install-headless-packages.sh"
"$ROOT_DIR/scripts/install-zsh-remote.sh"
"$ROOT_DIR/scripts/install-lazyvim.sh"
"$ROOT_DIR/scripts/install-tmux-remote.sh"
"$ROOT_DIR/scripts/install-opencode.sh"

printf 'Headless setup complete.\n'
