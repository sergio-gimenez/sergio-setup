#!/usr/bin/env bash
# One Claude Code memory for all Claude accounts, kept by agb (AgentBridge).
#
# Claude keeps auto-memory per project in <config>/projects/<project>/memory, so
# cc1 (~/.claude), cc2 (~/.claude-cc2), cc3 (~/.claude-cc3) each learn alone. agb's
# setup profile option "memory": {"share": ["cc1", "cc2", "cc3"]} keeps cc1's folders
# as the store (the OpenCode and Codex memory plugins read ~/.claude) and links the
# others' to them, merging what they already have first. agb only moves files; what it replaces goes
# to ~/.config/agentbridge/sync-backups/memory.
#
# A project another account opens later gets a real folder from Claude, so an hourly
# `agb sync` (systemd --user timer) merges and links those too.
set -euo pipefail

CONFIG="${AGB_CONFIG_PATH:-$HOME/.config/agentbridge/config.json}"
AGB="$(command -v agb || echo "$HOME/.local/bin/agb")"

if [ ! -x "$AGB" ] || [ ! -f "$CONFIG" ]; then
    printf 'Skipped shared Claude memory: agb or %s not found.\n' "$CONFIG"
    exit 0
fi
if ! jq -e '.setup.profiles' "$CONFIG" >/dev/null 2>&1; then
    printf 'Skipped shared Claude memory: no agb setup profile (agb setup --example).\n'
    exit 0
fi

# Every profile shares the memory of all the Claude accounts it targets, the
# first in agb's account list (cc1, ~/.claude) being the store. A new account
# (cc3, ...) added to claudeAccounts and the profile's targets joins on the next run.
tmp="$(mktemp)"
python3 - "$CONFIG" "$tmp" <<'PY'
import json, sys
config = json.load(open(sys.argv[1]))
claude = [account["name"] for account in config.get("claudeAccounts", [])]
for profile in config["setup"]["profiles"].values():
    targets = profile.get("targets", [])
    accounts = [name for name in claude if name in targets]
    share = profile.get("memory", {}).get("share", [])
    wanted = share + [name for name in accounts if name not in share]
    if len(wanted) >= 2 and wanted != share:
        profile["memory"] = {"share": wanted}
json.dump(config, open(sys.argv[2], "w"), indent=2, ensure_ascii=False)
open(sys.argv[2], "a").write("\n")
PY
if ! cmp -s "$tmp" "$CONFIG" && [ "$(jq -S . "$tmp")" != "$(jq -S . "$CONFIG")" ]; then
    cp -p "$CONFIG" "$CONFIG.bak-$(date +%F-%H%M%S)"
    cat "$tmp" > "$CONFIG"   # keeps the file's mode (0600)
    printf 'Shared memory accounts updated in %s\n' "$CONFIG"
fi
rm -f "$tmp"

status=0
for profile in $(jq -r '.setup.profiles | to_entries[] | select(.value.memory) | .key' "$CONFIG"); do
    if ! "$AGB" sync --profile "$profile" | grep -v '^present\|^shared\|^  /\|^  same destination'; then
        status=1
    fi
done
if [ "$status" != 0 ]; then
    printf 'agb sync did not finish; run `agb plan` to see the conflict.\n' >&2
fi

unit_dir="$HOME/.config/systemd/user"
mkdir -p "$unit_dir"
cat > "$unit_dir/agb-sync.service" <<EOF
[Unit]
Description=agb sync: shared skills, MCPs and Claude Code memory

[Service]
Type=oneshot
ExecStart=$AGB sync
EOF
cat > "$unit_dir/agb-sync.timer" <<'EOF'
[Unit]
Description=Hourly agb sync, so new Claude projects join the shared memory

[Timer]
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=5min

[Install]
WantedBy=timers.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now agb-sync.timer >/dev/null
printf 'Shared Claude memory set up; agb-sync.timer runs hourly.\n'
