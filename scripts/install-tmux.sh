#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install tmux
if ! command -v tmux &> /dev/null; then
    printf 'tmux not found. Installing...\n'
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y tmux
    else
        printf 'ERROR: No supported package manager found. Please install tmux manually.\n'
        exit 1
    fi
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR/.git" ]; then
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Install config
mkdir -p "$HOME/.config/tmux"
cp "$SCRIPT_DIR/../dotfiles/.tmux.conf" "$HOME/.config/tmux/tmux.conf"

printf 'Tmux config installed at ~/.config/tmux/tmux.conf\n'
printf 'Next steps:\n'
printf '  1. Install tmux plugins: open tmux and press Ctrl+Space then I (capital i)\n'
printf '  2. Prefix key is Ctrl+Space\n'
printf '  3. Sessions auto-save every 15 min and restore on boot\n'
