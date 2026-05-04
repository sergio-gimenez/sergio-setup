#!/usr/bin/env bash
set -euo pipefail

KERNEL=$(uname -r)

# Ensure headers present for DKMS
if ! dpkg -l | grep -q linux-headers-amd64; then
    sudo apt install -y linux-headers-amd64
fi

# Rebuild evdi for current kernel if missing
if ! ls /lib/modules/$KERNEL/updates/dkms/evdi.ko* 2>/dev/null; then
    sudo dkms autoinstall -k $KERNEL
fi

# Load evdi module
if ! lsmod | grep -q evdi; then
    sudo modprobe evdi
fi

# Restart displaylink service
sudo systemctl restart displaylink-driver

# Create evdi auto-load service if missing
if [ ! -f /etc/systemd/system/evdi-load.service ]; then
    sudo tee /etc/systemd/system/evdi-load.service > /dev/null <<'EOF'
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
    sudo systemctl enable evdi-load.service
fi

printf 'DisplayLink fixed for kernel %s.\n' "$KERNEL"
