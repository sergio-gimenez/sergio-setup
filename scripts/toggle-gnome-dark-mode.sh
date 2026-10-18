#!/usr/bin/env bash
# Toggle GNOME light/dark color scheme
# Ghostty will follow this automatically if configured with:
#   theme = light:THEME_NAME,dark:THEME_NAME

current=$(gsettings get org.gnome.desktop.interface color-scheme)
K9S_CONFIG="$HOME/.config/k9s/config.yaml"

if [ "$current" = "'prefer-dark'" ]; then
    gsettings set org.gnome.desktop.interface color-scheme default
    echo "Switched to light mode"
    NEW_K9S_SKIN="tokyonight-day"
    SCHEME_REPORT=$'\e[?997;2n'
    REPORT_MODE=2
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    echo "Switched to dark mode"
    NEW_K9S_SKIN="tokyonight-night"
    SCHEME_REPORT=$'\e[?997;1n'
    REPORT_MODE=1
fi

# The same Claude auto-theme race occurs in SSH-attached Herdr sessions on
# desk. Repeat the report there after the terminal has propagated its palette.
# Keep this in workstation setup: neither agb nor Herdr needs host-specific code.
(
    sleep 1.2
    ssh -o BatchMode=yes -o ConnectTimeout=3 desk "bash -s -- $REPORT_MODE" <<'REMOTE'
mode=$1
case "$mode" in 1|2) ;; *) exit 1 ;; esac
herdr_bin=$(command -v herdr || printf '%s/.local/bin/herdr' "$HOME")
report=$(printf '\033[?997;%sn' "$mode")
"$herdr_bin" pane list 2>/dev/null | python3 -c '
import json, sys
for pane in json.load(sys.stdin)["result"]["panes"]:
    if pane.get("agent") == "claude":
        print(pane["pane_id"])
' 2>/dev/null | while read -r pane; do
    "$herdr_bin" pane send-text "$pane" "$report" >/dev/null 2>&1
done
REMOTE
) >/dev/null 2>&1 &

# Update k9s skin if config exists
if [ -f "$K9S_CONFIG" ]; then
    python3 -c "
import yaml
with open('$K9S_CONFIG', 'r') as f:
    cfg = yaml.safe_load(f)
cfg.setdefault('k9s', {}).setdefault('ui', {})['skin'] = '$NEW_K9S_SKIN'
with open('$K9S_CONFIG', 'w') as f:
    yaml.dump(cfg, f, default_flow_style=False, sort_keys=False)
" 2>/dev/null || true
fi

# herdr tells its panes about a light/dark flip before it has the new
# background (herdrdev/herdr#4183), so Claude Code's theme "auto" re-reads the
# old colour and lands one switch behind. A second report, once herdr has the
# new colour, makes Claude read it again. Claude panes only: a shell or Codex
# would print the sequence as text. Backgrounded so the shortcut returns now.
HERDR="$(command -v herdr || echo "$HOME/.local/bin/herdr")"
if [ -x "$HERDR" ]; then
    (
        sleep 0.8
        "$HERDR" pane list 2>/dev/null | python3 -c '
import json, sys
for pane in json.load(sys.stdin)["result"]["panes"]:
    if pane.get("agent") == "claude":
        print(pane["pane_id"])
' 2>/dev/null | while read -r pane; do
            "$HERDR" pane send-text "$pane" "$SCHEME_REPORT" >/dev/null 2>&1
        done
    ) >/dev/null 2>&1 &
fi
