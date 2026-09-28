#!/usr/bin/env bash
set -euo pipefail

# Steam (Proton) + MangoHud + GameMode. Only for machines with a real GPU, such as
# the desk VM on gem12 with the 780M passed through. Needs contrib/non-free.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES="/etc/apt/sources.list.d/debian.sources"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

if [ -f "$SOURCES" ] && ! grep -q '^Components:.*non-free-firmware' "$SOURCES"; then
    run_as_root sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/' "$SOURCES"
fi

if ! dpkg --print-foreign-architectures | grep -qx i386; then
    run_as_root dpkg --add-architecture i386
fi
run_as_root apt-get update -q

# Pre-seed the Steam licence so the install doesn't stop on a dialog.
printf 'steam steam/question select I AGREE\nsteam steam/license note \n' | run_as_root debconf-set-selections

run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    steam-installer \
    mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
    libgl1-mesa-dri:i386 libglx-mesa0:i386 \
    firmware-amd-graphics vulkan-tools \
    mangohud gamemode

# Vulkan from SSH sessions, Sunshine and other headless users needs the render node;
# logind only grants it to local GNOME sessions.
for group in render video; do
    if ! id -nG "$USER" | grep -qw "$group"; then
        run_as_root usermod -aG "$group" "$USER"
    fi
done

printf 'Gaming stack installed. Start Steam once, then Settings > Compatibility > enable Steam Play for all titles.\n'
