#!/usr/bin/env bash
set -euo pipefail

# Ghostty isn't in the Debian archive. mkasberg/ghostty-ubuntu builds .debs for
# Debian trixie/forky and recent Ubuntu (linked from Ghostty's own install docs).
# Re-run this script to upgrade; there is no apt repo to pull updates from.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASES_API="https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

. /etc/os-release
case "$ID" in
    debian) TARGET="$VERSION_CODENAME" ;;
    ubuntu) TARGET="$VERSION_ID" ;;
    *) printf 'Skipped Ghostty. No package for %s.\n' "$ID" >&2; exit 0 ;;
esac
ARCH="$(dpkg --print-architecture)"

RELEASE_JSON="$(curl -fsSL "$RELEASES_API")"
DEB_URL="$(printf '%s' "$RELEASE_JSON" \
    | grep -oE "\"browser_download_url\": *\"[^\"]*_${ARCH}_${TARGET}\.deb\"" \
    | head -1 | sed -E 's/.*"(https[^"]+)"/\1/')"

if [ -z "$DEB_URL" ]; then
    printf 'Skipped Ghostty. Latest release has no %s build for %s.\n' "$ARCH" "$TARGET" >&2
    exit 0
fi

DEB_VERSION="$(basename "$DEB_URL" | sed -E 's/^ghostty_([^_]+)_.*/\1/')"
# dpkg records the "0.ppa2" in the file name as "0~ppa2"; compare them the same way.
INSTALLED="$(dpkg-query -W -f='${Version}' ghostty 2>/dev/null | tr '~' '.' || true)"

if [ "$INSTALLED" = "$DEB_VERSION" ]; then
    printf 'Ghostty %s already installed.\n' "$INSTALLED"
    exit 0
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
curl -fsSL "$DEB_URL" -o "$TMP_DIR/ghostty.deb"
chmod 644 "$TMP_DIR/ghostty.deb"
chmod 755 "$TMP_DIR"
run_as_root apt-get install -y "$TMP_DIR/ghostty.deb"

printf 'Ghostty %s installed from %s\n' "$DEB_VERSION" "$DEB_URL"
