# sergio-setup

Personal workstation bootstrap scripts.

## What it installs

- `keyd` with `Caps Lock` remapped to `Escape` for all keyboards
- Spanish (Catalan ·) keyboard layout via `localectl`
- English user directories (`Desktop`, `Downloads`, etc.)
- `gpaste-2` clipboard history manager with `Super+C` keybinding
- Neovim config from `https://github.com/sergio-gimenez/lazyvim-config`
- Ghostty terminal emulator built from source

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
./scripts/install-ghostty.sh
```

## Notes

- `install-keyd.sh` uses `pkexec` because it needs root access.
- `install-keyboard.sh` sets X11 keyboard to Spanish (Catalan ·) via `localectl`.
- `install-user-dirs.sh` sets user directories to English names.
- `install-lazyvim.sh` installs the config in `~/.config/nvim`.
- `install-lazyvim.sh` installs `git` and `neovim` if they are missing.
- If `~/.config/nvim` already exists and is not a git checkout, it is moved to a timestamped backup.
