#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$ROOT_DIR/.agents/skills"

cp -r ~/.agents/skills/caveman "$ROOT_DIR/.agents/skills/"
cp -r ~/.agents/skills/caveman-commit "$ROOT_DIR/.agents/skills/"
cp -r ~/.agents/skills/caveman-compress "$ROOT_DIR/.agents/skills/"
cp -r ~/.agents/skills/caveman-help "$ROOT_DIR/.agents/skills/"
cp -r ~/.agents/skills/caveman-review "$ROOT_DIR/.agents/skills/"

if [ -f ~/.agents/.skill-lock.json ]; then
  cp ~/.agents/.skill-lock.json "$ROOT_DIR/.agents/"
fi

cp "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/.agents/AGENTS.md"

mkdir -p "$HOME/.config/opencode/plugins"
cp "$ROOT_DIR/dotfiles/opencode/plugins/notifications.js" "$HOME/.config/opencode/plugins/"

printf 'Caveman skills and notification plugin installed.\n'