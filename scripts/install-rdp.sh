#!/usr/bin/env bash
set -euo pipefail

# Optional. GNOME Remote Login over RDP: every connection gets its own headless
# GNOME session sized to the client, starting at a GDM greeter. No monitor or
# autologin needed. Debian 13 / GNOME 48 needs three fixes on top of the package,
# all applied below; see "Why" at the bottom.
#
#   RDP_USER / RDP_PASSWORD   gate credentials (asked on a TTY if unset)
#
# The account itself also needs a usable password for the GDM greeter. Cloud
# images lock it; set one with `sudo passwd $USER`.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TLS_DIR="/var/lib/gnome-remote-desktop/.local/share/gnome-remote-desktop"
HANDOVER_DESKTOP="/usr/share/applications/org.gnome.RemoteDesktop.Handover.desktop"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

# grdctl talks to the running daemon; show its errors but drop the TPM notice
# it prints on every call inside a VM.
grd() {
    local out rc=0
    out="$(run_as_root grdctl --system "$@" 2>&1)" || rc=$?
    printf '%s\n' "$out" | grep -v 'TPM' >&2 || true
    return "$rc"
}

run_as_root apt-get install -y gnome-remote-desktop openssl

# Configure against a running daemon: with the service stopped, `rdp enable`
# returns 0 and doesn't stick.
run_as_root systemctl enable --now gnome-remote-desktop.service

# Self-signed TLS pair owned by the daemon's user.
if ! run_as_root test -f "$TLS_DIR/rdp-tls.crt"; then
    run_as_root install -d -o gnome-remote-desktop -g gnome-remote-desktop -m 700 "$TLS_DIR"
    run_as_root sudo -u gnome-remote-desktop openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/CN=$(hostname -f 2>/dev/null || hostname)" \
        -keyout "$TLS_DIR/rdp-tls.key" -out "$TLS_DIR/rdp-tls.crt" 2>/dev/null
fi
grd rdp set-tls-key "$TLS_DIR/rdp-tls.key"
grd rdp set-tls-cert "$TLS_DIR/rdp-tls.crt"
grd rdp enable

# Fix 1: the greeter session never starts the handover daemon, because Debian's
# gnome-login.session doesn't list it. GDM also reads this autostart dir.
run_as_root cp "$HANDOVER_DESKTOP" /usr/share/gdm/greeter/autostart/

# Fix 2: in the user session, start it as a session autostart, not via the
# systemd user unit. The unit (WantedBy=gnome-session.target) comes up before
# gnome-shell and gets stopped the moment the shell takes the session, crashing
# the handover. Drop X-GNOME-HiddenUnderSystemd so gnome-session runs it.
grep -v '^X-GNOME-HiddenUnderSystemd' "$HANDOVER_DESKTOP" \
    | { cat; printf 'OnlyShowIn=GNOME;\n'; } \
    | run_as_root tee /etc/xdg/autostart/org.gnome.RemoteDesktop.Handover.desktop >/dev/null
if systemctl --global is-enabled gnome-remote-desktop-handover.service >/dev/null 2>&1; then
    run_as_root systemctl --global disable gnome-remote-desktop-handover.service
fi

rdp_user="${RDP_USER:-}"
rdp_password="${RDP_PASSWORD:-}"
if { [ -z "$rdp_user" ] || [ -z "$rdp_password" ]; } && [ -t 0 ]; then
    [ -n "$rdp_user" ] || read -r -p "RDP user [$USER]: " rdp_user
    rdp_user="${rdp_user:-$USER}"
    [ -n "$rdp_password" ] || { read -r -s -p "RDP password: " rdp_password; printf '\n'; }
fi
if [ -n "$rdp_user" ] && [ -n "$rdp_password" ]; then
    grd rdp set-credentials "$rdp_user" "$rdp_password"
else
    printf 'RDP credentials not set. Re-run with RDP_USER and RDP_PASSWORD, or on a TTY.\n' >&2
fi

# Fix 3: without a TPM, credentials go to a GKeyFile the daemon only reads at
# start, so a running daemon keeps saying "Credentials are not set".
run_as_root systemctl restart gnome-remote-desktop.service

if ! run_as_root grdctl --system status 2>/dev/null | grep -qE 'Status: enabled'; then
    printf 'RDP backend did not stay enabled; check `sudo grdctl --system status`.\n' >&2
    exit 1
fi

if run_as_root passwd -S "$USER" 2>/dev/null | grep -qE "^$USER (L|NP) "; then
    printf 'Warning: %s has no usable password, the GDM greeter will refuse it. Run: sudo passwd %s\n' "$USER" "$USER" >&2
fi

printf 'RDP ready on port 3389. TLS fingerprint:\n'
run_as_root openssl x509 -in "$TLS_DIR/rdp-tls.crt" -noout -fingerprint -sha256
printf 'Client on Debian: use Remmina from Flathub (org.remmina.Remmina); 1.4.39 from apt crashes on the server redirection.\n'

# Why the handover matters: the client first reaches the system daemon, which
# starts a GDM greeter and redirects the client to a handover daemon inside it;
# after login the greeter's handover redirects again to one inside the user
# session. If either handover daemon is missing, the client sees a blank window.
