#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ./install.sh            full workstation setup
# ./install.sh --gaming   also Steam/MangoHud (machines with a real GPU, e.g. desk)
# ./install.sh --rdp      also GNOME Remote Login over RDP (see scripts/install-rdp.sh)
GAMING=0
RDP=0
for arg in "$@"; do
    case "$arg" in
        --gaming) GAMING=1 ;;
        --rdp) RDP=1 ;;
        *) printf 'Unknown option: %s\n' "$arg" >&2; exit 1 ;;
    esac
done

"$ROOT_DIR/scripts/install-cli-tools.sh"
"$ROOT_DIR/scripts/install-keyd.sh"
"$ROOT_DIR/scripts/install-keyboard.sh"
"$ROOT_DIR/scripts/install-user-dirs.sh"
"$ROOT_DIR/scripts/install-lazyvim.sh"
"$ROOT_DIR/scripts/install-latex.sh"
"$ROOT_DIR/scripts/install-gpaste.sh"
"$ROOT_DIR/scripts/install-flameshot.sh"
"$ROOT_DIR/scripts/install-zsh.sh"
"$ROOT_DIR/scripts/install-ghostty.sh"
"$ROOT_DIR/scripts/install-tmux.sh"
"$ROOT_DIR/scripts/install-k9s.sh"
"$ROOT_DIR/scripts/install-docker.sh"
"$ROOT_DIR/scripts/install-opencode.sh"
"$ROOT_DIR/scripts/install-agents.sh"
"$ROOT_DIR/scripts/install-syncthing.sh"
"$ROOT_DIR/scripts/install-logseq.sh"
"$ROOT_DIR/scripts/install-difi.sh"
"$ROOT_DIR/scripts/install-caveman.sh"
"$ROOT_DIR/scripts/install-flatpaks.sh"
"$ROOT_DIR/scripts/install-ghostty-config.sh"
"$ROOT_DIR/scripts/install-tactile.sh"
"$ROOT_DIR/scripts/sync-gnome-keybindings.sh"
"$ROOT_DIR/scripts/fix-displaylink.sh"

if [ "$GAMING" = 1 ]; then
    "$ROOT_DIR/scripts/install-gaming.sh"
fi

if [ "$RDP" = 1 ]; then
    "$ROOT_DIR/scripts/install-rdp.sh"
fi

printf '\nSetup complete.\n'
printf 'Log out and back in for all changes (shell, groups, keybindings) to take full effect.\n'
