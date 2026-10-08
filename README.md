# sergio-setup

Personal workstation bootstrap scripts.

## What it installs

- `keyd` with `Caps Lock` remapped to `Escape` for all keyboards, plus optional per-keyboard profiles in `keyd/profiles/`
- Spanish (Catalan ·) keyboard layout via `localectl` and GNOME input sources
- English user directories (`Desktop`, `Downloads`, etc.)
- CLI tools: `ripgrep`, `fd`, `zoxide`, `btop`, `jq`, `lazygit`, `shellcheck`, `gh` (GitHub apt repo), `glab` (GitLab release .deb)
- Neovim config from `https://github.com/sergio-gimenez/lazyvim-config`
- LaTeX: TeX Live, `latexmk`, `biber`, `chktex`, `zathura` (what the LazyVim `lang.tex` extra expects)
- `gpaste-2` clipboard history manager with `Super+C` keybinding
- `flameshot` bound to `Shift+Ctrl+Home`; GNOME's screenshot UI moved to `Shift+Ctrl+End`
- `zsh` with Oh-My-Zsh, `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `autoswitch_virtualenv`
- Ghostty from the `mkasberg/ghostty-ubuntu` .deb for the running Debian/Ubuntu release, with the Neovim theme (`dotfiles/ghostty/themes/tokyonight-nvim-{moon,day}`, following GNOME light/dark)
- herdr config in `dotfiles/herdr/` (tokyonight moon/day like Neovim, auto light/dark switch, Ghostty-style keys: `prefix+E`/`prefix+O` split down/right, `ctrl+tab`, `ctrl+alt+arrows`, `ctrl+shift+arrows` when Ghostty has no split); herdr itself is not installed here
- Docker CE from Docker's apt repo, plus `lazydocker`
- Agents: Node 24 from NodeSource when the system Node is older than 22, Claude Code (native installer), Codex and `claude-mermaid` (npm, prefix `~/.npm-global`), OpenCode with the `opencode-claude-memory` v2 plugin in `opencode.json` and the `tokyonight-nvim` theme (moon/day) in `cli.json`, Claude plugins `caveman` and `claude-code-wakatime`, `~/.wakatime.cfg` pointing at Wakapi, Claude Code `theme: auto` in `~/.claude*/settings.json`
- Flatpaks listed in `flatpaks.txt`
- Tactile GNOME extension with the config in `dotfiles/tactile/`
- GNOME keybindings and desktop preferences (dark mode, clock, numlock, hot corners)
- Syncthing with the user service enabled and `~/Sync` created
- Logseq graph cloned from Forgejo into `~/logseq-graph`, with managed shortcuts and plugin registry
- With `--gaming`: Steam (Proton), MangoHud, GameMode, i386 Mesa, and `render`/`video` group membership
- With `--rdp` (optional): GNOME Remote Login over RDP on port 3389, one headless GNOME session per connection

## Usage

Source machine bootstrap for a new laptop:

```bash
make bootstrap-remote HOST=sergio-personal-laptop
```

Then SSH into laptop, copy or pull this repo there, and run:

```bash
./install.sh
```

Run the full setup:

```bash
./install.sh
```

On a machine with a real GPU (the `desk` VM on gem12), add the gaming stack:

```bash
./install.sh --gaming
```

Optional remote desktop (GNOME Remote Login over RDP):

```bash
./install.sh --rdp                                        # or on its own:
RDP_USER=sergio RDP_PASSWORD=... ./scripts/install-rdp.sh
```

The account needs a real password for the GDM greeter (`sudo passwd $USER`;
cloud images lock it). Connect with Remmina from Flathub, which `flatpaks.txt`
installs. The Debian 1.4.39 package crashes on GNOME's server redirection.

Prompts only appear on a TTY. For unattended runs, answer them with env vars:

```bash
KEYD_PROFILES=sino-wealth WAKAPI_API_KEY=... ./install.sh
```

Run headless remote setup:

```bash
./install-headless.sh
```

Run individual parts:

```bash
./scripts/install-keyd.sh
./scripts/install-cli-tools.sh
./scripts/install-latex.sh
./scripts/install-docker.sh
./scripts/install-agents.sh
./scripts/install-flatpaks.sh
./scripts/install-tactile.sh
./scripts/install-gaming.sh
./scripts/install-keyboard.sh
./scripts/install-user-dirs.sh
./scripts/install-lazyvim.sh
./scripts/install-gpaste.sh
./scripts/install-flameshot.sh
./scripts/install-zsh.sh
./scripts/install-ghostty.sh
./scripts/install-syncthing.sh
./scripts/install-logseq.sh
./scripts/install-opencode.sh
./scripts/setup-remote-minimal.sh
./scripts/sync-ssh-to-remote.sh sergio-personal-laptop
./scripts/sync-agents-to-remote.sh sergio-personal-laptop
```

`install-headless.sh` installs headless remote dev tools only: `zsh`, `tmux`, LazyVim, OpenCode, `mosh`, and CLI dependencies. It skips GUI, desktop, and hardware-specific setup.

## Notes

- Root steps use `pkexec` in a local desktop session and `sudo` over SSH (`SUDO_PASSWORD` for scripted runs).
- `install-keyboard.sh` sets X11 keyboard to Spanish (Catalan ·) via `localectl`.
- `install-user-dirs.sh` sets user directories to English names.
- `install-lazyvim.sh` installs the config in `~/.config/nvim`.
- `install-lazyvim.sh` installs `git` and `neovim` if they are missing.
- If `~/.config/nvim` already exists and is not a git checkout, it is moved to a timestamped backup.
- `install-flameshot.sh` installs Flameshot; `sync-gnome-keybindings.sh` owns every GNOME shortcut, including the terminal on `Ctrl+Alt+T`.
- `install-keyd.sh` asks per profile in `keyd/profiles/` (`KEYD_PROFILES=all|none|<names>` skips the question). A profile that names a device id replaces `default.conf` for that keyboard. `sino-wealth` swaps PageUp and End.
- `install-ghostty.sh` has no apt repo to follow; re-run it to upgrade.
- `install-rdp.sh` patches three gaps in Debian 13's GNOME Remote Login: the GDM greeter doesn't start the handover daemon (autostart added to `/usr/share/gdm/greeter/autostart/`), the user-session handover unit gets stopped as gnome-shell starts (replaced by an `/etc/xdg/autostart` entry), and the daemon only reads credentials at start (restarted after `set-credentials`). A blank Remmina window means a handover daemon is missing; check `journalctl -u gnome-remote-desktop`.
- `install-agents.sh` never stores the Wakapi key in the repo: it reads `WAKAPI_API_KEY` or prompts. The Codex WakaTime plugin still needs adding by hand.
- `install-zsh.sh` installs Oh-My-Zsh and plugins, copies the `.zshrc` from `dotfiles/.zshrc`, and changes the default shell to zsh.
- `install-syncthing.sh` installs Syncthing, enables the `systemd --user` service, creates `~/Sync`, and prints the local device ID for phone pairing.
- `install-logseq.sh` clones `ssh://git@git.home.sergiogimenez.com/sergio/logseq-graph.git` when `~/logseq-graph` is missing, fast-forward pulls when the checkout is clean, and then restores the managed config into `~/logseq-graph/.logseq/config`.
- If the existing Logseq graph checkout has local changes, `install-logseq.sh` skips the pull and leaves your worktree untouched.
- `scripts/sync-ssh-to-remote.sh` is a source-machine helper: it copies your local `~/.ssh` to a remote machine and fixes permissions so private Git remotes work before setup.
- `scripts/sync-agents-to-remote.sh` is a source-machine helper: it copies your local `~/.agents` to a remote machine so Caveman skills and lockfiles exist before setup.
- `make bootstrap-remote HOST=...` runs source-side bootstrap helpers for a new machine.
- Set `SYNCTHING_SYNC_DIR`, `LOGSEQ_GRAPH_DIR`, or `LOGSEQ_GRAPH_REPO_URL` before running a script if you want different target paths or a different remote.
