#!/usr/bin/env bash
set -euo pipefail

# Minimal remote dev server bootstrap
# Run this on the machine you want to access from your tablet

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

printf '=== Remote Minimal Dev Server Setup ===\n\n'

# 1. Core packages
printf '[*] Installing core packages...\n'
sudo apt update
sudo apt install -y \
    git \
    neovim \
    zsh \
    fzf \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    tmux \
    mosh \
    curl \
    wget \
    rsync \
    build-essential \
    python3 \
    python3-venv \
    nodejs \
    npm \
    cargo \
    ruby

# 2. Tectonic (lightweight LaTeX) - install prebuilt binary
if ! command -v tectonic >/dev/null 2>&1; then
    printf '[*] Installing Tectonic (LaTeX) from prebuilt binary...\n'
    TECTONIC_URL="https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.16.9/tectonic-0.16.9-x86_64-unknown-linux-gnu.tar.gz"
    curl -fsSL "$TECTONIC_URL" | tar xz -C /usr/local/bin
    chmod +x /usr/local/bin/tectonic
    printf '[*] Tectonic installed to /usr/local/bin/tectonic\n'
fi

# 3. Zsh setup (lightweight, no Oh-My-Zsh)
ZSHRC_TARGET="$HOME/.zshrc"
ZSHRC_BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
ZSHRC_SOURCE="$ROOT_DIR/dotfiles/.zshrc-remote"

if [ -e "$ZSHRC_TARGET" ] && [ ! -L "$ZSHRC_TARGET" ]; then
    cp "$ZSHRC_TARGET" "$ZSHRC_BACKUP"
    printf 'Backed up existing .zshrc to %s\n' "$ZSHRC_BACKUP"
fi

if [ -f "$ZSHRC_SOURCE" ]; then
    cp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
    printf '[*] Installed remote .zshrc\n'
else
    printf '[!] Warning: %s not found, skipping zsh config copy\n' "$ZSHRC_SOURCE"
fi

if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(which zsh)"
    printf 'Default shell changed to zsh. Log out and back in for changes to take effect.\n'
fi

# 4. LazyVim config
printf '[*] Setting up LazyVim config...\n'
LAZYVIM_REPO="https://github.com/sergio-gimenez/lazyvim-config"
NVIM_DIR="$HOME/.config/nvim"
NVIM_BACKUP="$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"

mkdir -p "$HOME/.config"

if [ -e "$NVIM_DIR" ] && [ ! -d "$NVIM_DIR/.git" ] && [ ! -L "$NVIM_DIR" ]; then
    mv "$NVIM_DIR" "$NVIM_BACKUP"
    printf 'Moved existing nvim config to %s\n' "$NVIM_BACKUP"
fi

if [ -d "$NVIM_DIR/.git" ]; then
    CURRENT_REMOTE="$(git -C "$NVIM_DIR" remote get-url origin 2>/dev/null || true)"
    if [ "$CURRENT_REMOTE" = "$LAZYVIM_REPO" ] || [ "$CURRENT_REMOTE" = "git@github.com:sergio-gimenez/lazyvim-config.git" ]; then
        git -C "$NVIM_DIR" pull --ff-only
    else
        mv "$NVIM_DIR" "$NVIM_BACKUP"
        git clone "$LAZYVIM_REPO" "$NVIM_DIR"
    fi
else
    rm -rf "$NVIM_DIR"
    git clone "$LAZYVIM_REPO" "$NVIM_DIR"
fi

# 5. Tmux config (basic)
TMUX_CONF="$HOME/.tmux.conf"
if [ ! -e "$TMUX_CONF" ]; then
    cat > "$TMUX_CONF" << 'EOF'
# Basic tmux config for remote/mobile use
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"
set -g mouse on
set -g history-limit 10000

# Prefix key
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Window splits
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Easy config reload
bind r source-file ~/.tmux.conf \; display "Reloaded!"

# Fast window switching
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Status bar
set -g status-style bg=black,fg=white
set -g window-status-current-style bg=blue,fg=white,bold
EOF
    printf '[*] Created basic ~/.tmux.conf\n'
fi

# 6. Syncthing (optional, user service)
if command -v syncthing >/dev/null 2>&1; then
    printf '[*] Syncthing already installed\n'
else
    printf '[*] You can install syncthing later with: sudo apt install syncthing\n'
fi

# 7. Tailscale hint
if ! command -v tailscale >/dev/null 2>&1; then
    printf '\n[!] Tailscale not found. Install it for easy remote access:\n'
    printf '    curl -fsSL https://tailscale.com/install.sh | sh\n'
    printf '    sudo tailscale up\n'
fi

printf '\n=== Remote setup complete ===\n'
printf 'Next steps:\n'
printf '  1. Log out and back in (or run: exec zsh)\n'
printf '  2. Open nvim to let LazyVim install plugins (takes a few minutes)\n'
printf '  3. On your tablet, install Termux and: pkg install mosh\n'
printf '  4. Connect: mosh user@your-server-ip -- tmux new -A -s main\n'
