#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/sergio-gimenez/lazyvim-config"
TARGET_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
ALT_REPO_URL="git@github.com:sergio-gimenez/lazyvim-config.git"

# Prefer pkexec in local desktop sessions. Fall back to sudo for SSH/headless runs.
source "$SCRIPT_DIR/lib/run-as-root.sh"

if ! command -v git >/dev/null 2>&1; then
    run_as_root apt install -y git
fi

NVIM_MIN_VERSION="0.11.2"
NVIM_LOCAL_DIR="$HOME/.local/opt/nvim"
NVIM_BIN="$NVIM_LOCAL_DIR/bin/nvim"

needs_nvim_install() {
    if ! command -v nvim >/dev/null 2>&1; then
        return 0
    fi
    local current_version
    current_version="$(nvim --version | head -1 | sed 's/NVIM v//')"
    if [ "$(printf '%s\n%s' "$NVIM_MIN_VERSION" "$current_version" | sort -V | head -n1)" != "$NVIM_MIN_VERSION" ]; then
        return 0
    fi
    return 1
}

if needs_nvim_install; then
    if command -v apt-get >/dev/null 2>&1; then
        run_as_root apt-get install -y neovim 2>/dev/null || true
    fi
fi

if needs_nvim_install; then
    printf 'Neovim >= %s not available via package manager. Installing binary release...\n' "$NVIM_MIN_VERSION"
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64) NVIM_TARBALL="nvim-linux-x86_64.tar.gz" ;;
        aarch64) NVIM_TARBALL="nvim-linux-arm64.tar.gz" ;;
        *)
            printf 'ERROR: Unsupported architecture for Neovim binary: %s\n' "$ARCH" >&2
            exit 1
            ;;
    esac
    TMP_DIR="$(mktemp -d)"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/$NVIM_TARBALL" -o "$TMP_DIR/nvim.tar.gz"
    rm -rf "$NVIM_LOCAL_DIR"
    mkdir -p "$NVIM_LOCAL_DIR"
    tar -C "$NVIM_LOCAL_DIR" --strip-components=1 -xzf "$TMP_DIR/nvim.tar.gz"
    rm -rf "$TMP_DIR"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$NVIM_BIN" "$HOME/.local/bin/nvim"
    printf 'Neovim binary installed in %s\n' "$NVIM_LOCAL_DIR"
fi

mkdir -p "$HOME/.config"

if [ -e "$TARGET_DIR" ] && [ ! -d "$TARGET_DIR/.git" ] && [ ! -L "$TARGET_DIR" ]; then
    mv "$TARGET_DIR" "$BACKUP_DIR"
    printf 'Moved existing nvim config to %s\n' "$BACKUP_DIR"
fi

if [ -d "$TARGET_DIR/.git" ]; then
    CURRENT_REMOTE="$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)"

    if [ "$CURRENT_REMOTE" = "$REPO_URL" ] || [ "$CURRENT_REMOTE" = "$ALT_REPO_URL" ]; then
        git -C "$TARGET_DIR" pull --ff-only
    else
        mv "$TARGET_DIR" "$BACKUP_DIR"
        printf 'Moved existing git-based nvim config to %s\n' "$BACKUP_DIR"
        git clone "$REPO_URL" "$TARGET_DIR"
    fi
else
    rm -rf "$TARGET_DIR"
    git clone "$REPO_URL" "$TARGET_DIR"
fi

printf 'LazyVim config installed in %s\n' "$TARGET_DIR"
