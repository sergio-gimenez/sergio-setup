#!/usr/bin/env bash
set -euo pipefail

KERNEL=$(uname -r)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

# Ensure headers present for DKMS
if ! dpkg -l | grep -q linux-headers-amd64; then
    run_as_root apt install -y linux-headers-amd64
fi

# Rebuild evdi for current kernel if missing
if ! ls /lib/modules/$KERNEL/updates/dkms/evdi.ko* 2>/dev/null; then
    run_as_root dkms autoinstall -k "$KERNEL"
fi

# Load evdi module
if ! lsmod | grep -q evdi; then
    run_as_root modprobe evdi
fi

# Restart displaylink service
run_as_root systemctl restart displaylink-driver

# Create evdi auto-load service if missing
if [ ! -f /etc/systemd/system/evdi-load.service ]; then
    SERVICE_FILE="$(mktemp)"
    cat > "$SERVICE_FILE" <<'EOF'
[Unit]
Description=Load evdi module
After=displaylink-driver.service

[Service]
Type=oneshot
ExecStart=/sbin/modprobe evdi
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    run_as_root cp "$SERVICE_FILE" /etc/systemd/system/evdi-load.service
    rm -f "$SERVICE_FILE"
    run_as_root systemctl enable evdi-load.service
fi

printf 'DisplayLink fixed for kernel %s.\n' "$KERNEL"
