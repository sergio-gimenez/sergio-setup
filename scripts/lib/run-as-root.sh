#!/usr/bin/env bash

run_as_root() {
    if command -v pkexec >/dev/null 2>&1 \
        && [ -n "${DISPLAY:-}" ] \
        && [ -z "${SSH_CONNECTION:-}" ] \
        && [ -z "${SSH_TTY:-}" ]; then
        pkexec "$@"
        return
    fi

    if [ -n "${SUDO_PASSWORD:-}" ]; then
        printf '%s\n' "$SUDO_PASSWORD" | sudo -S "$@"
        return
    fi

    sudo "$@"
}
