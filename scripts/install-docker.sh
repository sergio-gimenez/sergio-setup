#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/run-as-root.sh"

. /etc/os-release

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    run_as_root install -d -m 755 /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/$ID/gpg" | run_as_root tee /etc/apt/keyrings/docker.asc >/dev/null
    run_as_root chmod 644 /etc/apt/keyrings/docker.asc
    printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/%s %s stable\n' \
        "$(dpkg --print-architecture)" "$ID" "$VERSION_CODENAME" \
        | run_as_root tee /etc/apt/sources.list.d/docker.list >/dev/null
    run_as_root apt-get update -q
fi

run_as_root apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if ! id -nG "$USER" | grep -qw docker; then
    run_as_root usermod -aG docker "$USER"
    printf 'Added %s to docker group. Log out and back in to use docker without sudo.\n' "$USER"
fi

# lazydocker only ships release tarballs.
if [ ! -x "$HOME/.local/bin/lazydocker" ]; then
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh \
        | DIR="$HOME/.local/bin" bash
fi

printf 'Docker installed.\n'
