#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SOURCE="$ROOT_DIR/keyd/default.conf"
CONFIG_TARGET="/etc/keyd/default.conf"
PROFILES_DIR="$ROOT_DIR/keyd/profiles"

# Per-keyboard profiles in keyd/profiles/. keyd prefers a config that names the
# device id over the wildcard in default.conf, so a profile fully replaces it for
# that keyboard.
#   KEYD_PROFILES="sino-wealth"   install these (space separated)
#   KEYD_PROFILES=all | none      install every profile / none
#   unset                         ask for each one on a TTY, install none otherwise
KEYD_PROFILES="${KEYD_PROFILES-}"

# Prefer pkexec in local desktop sessions. Fall back to sudo for SSH/headless runs.
source "$ROOT_DIR/scripts/lib/run-as-root.sh"

if ! command -v keyd.rvaiya >/dev/null 2>&1; then
    run_as_root apt install -y keyd
fi

want_profile() {
    local name="$1" file="$2" answer

    case " $KEYD_PROFILES " in
        " all ") return 0 ;;
        " none ") return 1 ;;
        *" $name "*) return 0 ;;
    esac

    if [ -n "$KEYD_PROFILES" ] || [ ! -t 0 ]; then
        return 1
    fi

    printf '\n%s\n' "$(sed -n 's/^# //p' "$file" | head -1)"
    read -r -p "Install keyd profile '$name'? [y/N] " answer
    [[ "$answer" =~ ^[yY] ]]
}

run_as_root mkdir -p /etc/keyd
run_as_root cp "$CONFIG_SOURCE" "$CONFIG_TARGET"

for profile in "$PROFILES_DIR"/*.conf; do
    [ -e "$profile" ] || continue
    name="$(basename "$profile" .conf)"
    if want_profile "$name" "$profile"; then
        run_as_root cp "$profile" "/etc/keyd/$name.conf"
        printf 'Installed keyd profile %s\n' "$name"
    elif [ -e "/etc/keyd/$name.conf" ]; then
        run_as_root rm -f "/etc/keyd/$name.conf"
        printf 'Removed keyd profile %s\n' "$name"
    fi
done

run_as_root systemctl enable --now keyd
run_as_root systemctl restart keyd

if getent group keyd >/dev/null 2>&1 && ! id -nG "$USER" | grep -qw keyd; then
    run_as_root usermod -aG keyd "$USER"
    printf 'Added %s to keyd group. Log out and back in for full access.\n' "$USER"
fi

printf 'Installed keyd config to %s\n' "$CONFIG_TARGET"
