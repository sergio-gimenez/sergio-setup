#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

# Install k9s
if ! command -v k9s &> /dev/null; then
    printf 'k9s not found. Installing...\n'
    if command -v apt-get &> /dev/null; then
        run_as_root apt-get update
        if apt-cache show k9s >/dev/null 2>&1; then
            run_as_root apt-get install -y k9s
        else
            TMP_DIR="$(mktemp -d)"
            ARCH="$(dpkg --print-architecture)"

            case "$ARCH" in
                amd64) K9S_DEB_URL="https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb" ;;
                arm64) K9S_DEB_URL="https://github.com/derailed/k9s/releases/latest/download/k9s_linux_arm64.deb" ;;
                *)
                    printf 'ERROR: Unsupported k9s architecture: %s\n' "$ARCH"
                    rm -rf "$TMP_DIR"
                    exit 1
                    ;;
            esac

            curl -fsSL "$K9S_DEB_URL" -o "$TMP_DIR/k9s.deb"
            run_as_root apt-get install -y "$TMP_DIR/k9s.deb"
            rm -rf "$TMP_DIR"
        fi
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
