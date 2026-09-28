#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/run-as-root.sh"

run_as_root apt-get update -q
run_as_root apt-get install -y \
    ripgrep fd-find zoxide btop jq tree entr shellcheck lazygit \
    curl wget gpg ca-certificates

# Debian ships fd as fdfind to avoid a name clash.
mkdir -p "$HOME/.local/bin"
if command -v fdfind >/dev/null 2>&1 && [ ! -e "$HOME/.local/bin/fd" ]; then
    ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# gh: Debian's is far behind, use GitHub's apt repo.
if [ ! -f /etc/apt/sources.list.d/github-cli.list ]; then
    run_as_root install -d -m 755 /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | run_as_root tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    run_as_root chmod 644 /etc/apt/keyrings/githubcli-archive-keyring.gpg
    printf 'deb [arch=%s signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' \
        "$(dpkg --print-architecture)" \
        | run_as_root tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    run_as_root apt-get update -q
fi
run_as_root apt-get install -y gh

# glab: GitLab publishes a .deb per release; Debian's is ~30 versions behind.
GLAB_API="https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest"
GLAB_TAG="$(curl -fsSL "$GLAB_API" | grep -oE '"tag_name":"v[^"]+"' | head -1 | sed -E 's/.*"v([^"]+)"/\1/')"
if [ -n "$GLAB_TAG" ] && [ "$(dpkg-query -W -f='${Version}' glab 2>/dev/null || true)" != "$GLAB_TAG" ]; then
    TMP_DIR="$(mktemp -d)"
    curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_TAG}/downloads/glab_${GLAB_TAG}_linux_$(dpkg --print-architecture).deb" \
        -o "$TMP_DIR/glab.deb"
    chmod 755 "$TMP_DIR"; chmod 644 "$TMP_DIR/glab.deb"
    run_as_root apt-get install -y "$TMP_DIR/glab.deb"
    rm -rf "$TMP_DIR"
elif [ -z "$GLAB_TAG" ]; then
    printf 'Could not resolve latest glab release, falling back to Debian package.\n' >&2
    run_as_root apt-get install -y glab
fi

printf 'CLI tools installed.\n'
