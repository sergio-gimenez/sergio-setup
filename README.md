# sergio-setup

Personal workstation bootstrap scripts.

## What it installs

- `keyd` with `Caps Lock` remapped to `Escape` for all keyboards
- Spanish (Catalan ·) keyboard layout via `localectl`
- English user directories (`Desktop`, `Downloads`, etc.)
- `gpaste-2` clipboard history manager with `Super+C` keybinding
- `flameshot` with `Print Screen` keybinding (replaces GNOME default screenshot shortcut)
- `zsh` with Oh-My-Zsh, `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `autoswitch_virtualenv`
- Neovim config from `https://github.com/sergio-gimenez/lazyvim-config`
- Ghostty terminal emulator built from source
- Syncthing with the user service enabled and `~/Sync` created
- Logseq graph cloned from Forgejo into `~/logseq-graph`, with managed shortcuts and plugin registry

## Usage

Run the full setup:

```bash
./install.sh
```

Run individual parts:

```bash
./scripts/install-keyd.sh
./scripts/install-keyboard.sh
./scripts/install-user-dirs.sh
./scripts/install-lazyvim.sh
./scripts/install-gpaste.sh
./scripts/install-flameshot.sh
./scripts/install-zsh.sh
./scripts/install-ghostty.sh
./scripts/install-syncthing.sh
./scripts/install-logseq.sh
```

## Notes

- `install-keyd.sh` uses `pkexec` because it needs root access.
- `install-keyboard.sh` sets X11 keyboard to Spanish (Catalan ·) via `localectl`.
- `install-user-dirs.sh` sets user directories to English names.
- `install-lazyvim.sh` installs the config in `~/.config/nvim`.
- `install-lazyvim.sh` installs `git` and `neovim` if they are missing.
- If `~/.config/nvim` already exists and is not a git checkout, it is moved to a timestamped backup.
- `install-flameshot.sh` disables GNOME's default Print Screen shortcut and binds it to `flameshot gui`.
- `install-zsh.sh` installs Oh-My-Zsh and plugins, copies the `.zshrc` from `dotfiles/.zshrc`, and changes the default shell to zsh.
- `install-syncthing.sh` installs Syncthing, enables the `systemd --user` service, creates `~/Sync`, and prints the local device ID for phone pairing.
- `install-logseq.sh` clones `ssh://git@git.home.sergiogimenez.com/sergio/logseq-graph.git` when `~/logseq-graph` is missing, fast-forward pulls when the checkout is clean, and then restores the managed config into `~/logseq-graph/.logseq/config`.
- If the existing Logseq graph checkout has local changes, `install-logseq.sh` skips the pull and leaves your worktree untouched.
- Set `SYNCTHING_SYNC_DIR`, `LOGSEQ_GRAPH_DIR`, or `LOGSEQ_GRAPH_REPO_URL` before running a script if you want different target paths or a different remote.
