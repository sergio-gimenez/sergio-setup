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
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    echo "Switched to dark mode"
    NEW_K9S_SKIN="tokyonight-night"
fi

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
