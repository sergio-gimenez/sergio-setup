#!/usr/bin/env bash
set -euo pipefail

# Coding agents: Claude Code, Codex, and WakaTime-compatible tracking against the
# self-hosted Wakapi. OpenCode is install-opencode.sh; its memory plugin shared with
# Claude Code (opencode-claude-memory) is listed in dotfiles/opencode/opencode.json
# and OpenCode fetches it itself.
#
#   WAKAPI_API_KEY=...   write ~/.wakatime.cfg without prompting

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NPM_PREFIX="$HOME/.npm-global"
WAKAPI_API_URL="https://wakapi.sergiogimenez.com/api/compat/wakatime/v1"

source "$ROOT_DIR/scripts/lib/run-as-root.sh"

NODE_MIN_MAJOR=22
NODE_MAJOR=24

# Debian 13 ships Node 20; puppeteer (pulled in by claude-mermaid) wants 22+.
# NodeSource's nodejs bundles npm and conflicts with Debian's npm package.
node_major() {
    command -v node >/dev/null 2>&1 || return 0
    node --version | sed -E 's/^v([0-9]+).*/\1/'
}
current="$(node_major)"
if [ -z "$current" ] || [ "$current" -lt "$NODE_MIN_MAJOR" ]; then
    run_as_root install -d -m 755 /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor | run_as_root tee /etc/apt/keyrings/nodesource.gpg >/dev/null
    run_as_root chmod 644 /etc/apt/keyrings/nodesource.gpg
    printf 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_%s.x nodistro main\n' "$NODE_MAJOR" \
        | run_as_root tee /etc/apt/sources.list.d/nodesource.list >/dev/null
    run_as_root apt-get update -q
    run_as_root apt-get remove -y npm 2>/dev/null || true
    run_as_root apt-get install -y nodejs
fi

# Global npm packages go under $HOME, no root needed. .zshrc puts the bin dir on PATH.
npm config set prefix "$NPM_PREFIX"
export PATH="$NPM_PREFIX/bin:$HOME/.local/bin:$PATH"
npm install -g @openai/codex claude-mermaid

if ! command -v claude >/dev/null 2>&1; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

claude plugin marketplace add JuliusBrussee/caveman 2>/dev/null || true
claude plugin marketplace add https://github.com/wakatime/claude-code-wakatime.git 2>/dev/null || true
claude plugin install caveman@caveman 2>/dev/null || true
claude plugin install claude-code-wakatime@wakatime 2>/dev/null || true

# theme "auto" follows the terminal's light/dark (ctrl+alt+shift+d), also through herdr.
# Edit in place: settings.json holds other per-machine state. cc1/cc2 are the account dirs.
for dir in "$HOME/.claude" "$HOME/.claude-cc1" "$HOME/.claude-cc2"; do
    settings="$dir/settings.json"
    [ -d "$dir" ] || continue
    [ -s "$settings" ] || printf '{}\n' > "$settings"
    tmp="$(mktemp)"
    jq '.theme = "auto"' "$settings" > "$tmp" && mv "$tmp" "$settings"
done

if [ ! -f "$HOME/.wakatime.cfg" ]; then
    key="${WAKAPI_API_KEY:-}"
    if [ -z "$key" ] && [ -t 0 ]; then
        read -r -s -p "Wakapi API key (empty to skip): " key
        printf '\n'
    fi
    if [ -n "$key" ]; then
        umask 077
        printf '[settings]\napi_key = %s\napi_url = %s\n' "$key" "$WAKAPI_API_URL" > "$HOME/.wakatime.cfg"
        printf 'Wrote ~/.wakatime.cfg pointing at Wakapi.\n'
    else
        printf 'Skipped ~/.wakatime.cfg. Set WAKAPI_API_KEY and re-run to add it.\n'
    fi
fi

printf 'Agents installed. Codex WakaTime plugin still needs adding by hand in ~/.codex/config.toml.\n'
