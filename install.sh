#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$ROOT_DIR/scripts/install-keyd.sh"
"$ROOT_DIR/scripts/install-keyboard.sh"
"$ROOT_DIR/scripts/install-user-dirs.sh"
"$ROOT_DIR/scripts/install-lazyvim.sh"
"$ROOT_DIR/scripts/install-gpaste.sh"

printf 'Setup complete.\n'
