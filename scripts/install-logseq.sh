#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGSEQ_GRAPH_DIR="${LOGSEQ_GRAPH_DIR:-$HOME/logseq-graph}"
LOGSEQ_GRAPH_REPO_URL="${LOGSEQ_GRAPH_REPO_URL:-ssh://git@git.home.sergiogimenez.com/sergio/logseq-graph.git}"
LOGSEQ_CONFIG_DIR="$LOGSEQ_GRAPH_DIR/.logseq/config"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

backup_file() {
    local target="$1"

    if [ -f "$target" ]; then
        cp "$target" "$target.backup.$TIMESTAMP"
        printf 'Backed up %s to %s.backup.%s\n' "$target" "$target" "$TIMESTAMP"
    fi
}

if [ ! -d "$LOGSEQ_GRAPH_DIR/.git" ]; then
    if [ -e "$LOGSEQ_GRAPH_DIR" ]; then
        printf 'Logseq graph path exists but is not a git checkout: %s\n' "$LOGSEQ_GRAPH_DIR" >&2
        exit 1
    fi

    git clone "$LOGSEQ_GRAPH_REPO_URL" "$LOGSEQ_GRAPH_DIR"
elif [ -z "$(git -C "$LOGSEQ_GRAPH_DIR" status --porcelain)" ]; then
    git -C "$LOGSEQ_GRAPH_DIR" pull --ff-only
else
    printf 'Skipped pulling %s because it has local changes.\n' "$LOGSEQ_GRAPH_DIR"
fi

mkdir -p "$LOGSEQ_CONFIG_DIR"

backup_file "$LOGSEQ_CONFIG_DIR/config.edn"
backup_file "$LOGSEQ_CONFIG_DIR/plugins.edn"

install -Dm644 "$ROOT_DIR/logseq/config.edn" "$LOGSEQ_CONFIG_DIR/config.edn"
install -Dm644 "$ROOT_DIR/logseq/plugins.edn" "$LOGSEQ_CONFIG_DIR/plugins.edn"

printf 'Restored Logseq graph config to %s\n' "$LOGSEQ_GRAPH_DIR"
printf 'Managed files: %s and %s\n' "$LOGSEQ_CONFIG_DIR/config.edn" "$LOGSEQ_CONFIG_DIR/plugins.edn"
printf 'Graph remote: %s\n' "$LOGSEQ_GRAPH_REPO_URL"
