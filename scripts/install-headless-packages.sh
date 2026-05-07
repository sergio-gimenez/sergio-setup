#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
    printf 'ERROR: apt-get not found. Install packages manually.\n'
    exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
    SUDO_CMD=()
else
    SUDO_CMD=(sudo)
fi

"${SUDO_CMD[@]}" apt-get update
"${SUDO_CMD[@]}" apt-get install -y \
    build-essential \
    cargo \
    curl \
    fzf \
    git \
    locales \
    mosh \
    neovim \
    nodejs \
    npm \
    python3 \
    python3-venv \
    ripgrep \
    rsync \
    ruby \
    tmux \
    wget \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting

if locale -a | grep -qx 'en_US.utf8'; then
    exit 0
fi

"${SUDO_CMD[@]}" sed -i 's/^# *en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' /etc/locale.gen
"${SUDO_CMD[@]}" locale-gen en_US.UTF-8
