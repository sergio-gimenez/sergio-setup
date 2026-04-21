#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC_SOURCE="$ROOT_DIR/dotfiles/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"
ZSHRC_BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"

if ! command -v zsh >/dev/null 2>&1; then
    sudo apt install -y zsh
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

sudo apt install -y fzf zsh-autosuggestions zsh-syntax-highlighting

AUTOSWITCH_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autoswitch_virtualenv"
if [ ! -d "$AUTOSWITCH_DIR" ]; then
    git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" "$AUTOSWITCH_DIR"
fi

if [ -e "$ZSHRC_TARGET" ] && [ ! -L "$ZSHRC_TARGET" ]; then
    cp "$ZSHRC_TARGET" "$ZSHRC_BACKUP"
    printf 'Backed up existing .zshrc to %s\n' "$ZSHRC_BACKUP"
fi

cp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"

if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(which zsh)"
    printf 'Default shell changed to zsh. Please log out and back in for changes to take effect.\n'
fi

printf 'Zsh and Oh-My-Zsh setup complete.\n'
