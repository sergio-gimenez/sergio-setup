#!/usr/bin/env bash
set -euo pipefail

pkexec localectl set-x11-keymap es pc105 cat

printf 'Keyboard layout set to Spanish (Catalan ·)\n'
