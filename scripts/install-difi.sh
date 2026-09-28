#!/usr/bin/env bash
# Install difi config
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$HOME/.config/difi"
cp "$ROOT_DIR/dotfiles/difi/config.yaml" "$HOME/.config/difi/config.yaml"

printf 'difi config installed in ~/.config/difi/config.yaml\n'
