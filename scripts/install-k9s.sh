#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install k9s
if ! command -v k9s &> /dev/null; then
    printf 'k9s not found. Installing...\n'
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y k9s
    else
        printf 'ERROR: No supported package manager found. Please install k9s manually.\n'
        exit 1
    fi
fi

# Install TokyoNight skins
mkdir -p "$HOME/.config/k9s/skins"
cp "$SCRIPT_DIR/../dotfiles/k9s-skins/tokyonight-night.yaml" "$HOME/.config/k9s/skins/"
cp "$SCRIPT_DIR/../dotfiles/k9s-skins/tokyonight-day.yaml" "$HOME/.config/k9s/skins/"

# Install themed wrapper
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/k9s-themed" "$HOME/.local/bin/k9s-themed"
chmod +x "$HOME/.local/bin/k9s-themed"

printf 'k9s installed with TokyoNight skins and themed wrapper (k9s-themed).\n'
