#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_URL="https://github.com/ghostty-org/ghostty"
TARGET_DIR="$HOME/.local/src/ghostty"
ZIG_VERSION="0.15.2"
ZIG_DIR="$HOME/.local/opt/zig-$ZIG_VERSION"
ZIG_BIN="$ZIG_DIR/zig"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

if ! command -v tar >/dev/null 2>&1; then
    run_as_root apt install -y tar
fi

if ! command -v xz >/dev/null 2>&1; then
    run_as_root apt install -y xz-utils
fi

run_as_root apt install -y libgtk-4-dev libgtk4-layer-shell-dev libadwaita-1-dev gettext libxml2-utils blueprint-compiler pkgconf gcc-multilib

if [ ! -x "$ZIG_BIN" ]; then
    mkdir -p "$(dirname "$ZIG_DIR")"
    TMP_DIR="$(mktemp -d)"
    curl -fsSL "https://ziglang.org/download/$ZIG_VERSION/zig-x86_64-linux-$ZIG_VERSION.tar.xz" -o "$TMP_DIR/zig.tar.xz"
    tar -C "$TMP_DIR" -xf "$TMP_DIR/zig.tar.xz"
    rm -rf "$ZIG_DIR"
    mv "$TMP_DIR/zig-x86_64-linux-$ZIG_VERSION" "$ZIG_DIR"
    rm -rf "$TMP_DIR"
fi

if [ -d "$TARGET_DIR/.git" ]; then
    git -C "$TARGET_DIR" pull --ff-only
else
    mkdir -p "$(dirname "$TARGET_DIR")"
    git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"
"$ZIG_BIN" build -p "$HOME/.local" -Doptimize=ReleaseFast -Dcpu=baseline

printf 'Ghostty installed in %s and %s\n' "$TARGET_DIR" "$HOME/.local"
