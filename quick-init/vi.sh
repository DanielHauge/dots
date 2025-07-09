#!/bin/bash

set -euo pipefail

DOTS_LOC="$1"
export DOTS_LOC

# make temp directory of nvim data

if [[ -n "${TMPDIR:-}" ]]; then
    TMPBASE="$TMPDIR"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    TMPBASE="${TEMP:-${TMP:-/tmp}}"
else
    TMPBASE="/tmp"
fi
XDG_DATA_HOME="$(mktemp -d "$TMPBASE/daniel-nvim-data.XXXXXX")"
export XDG_DATA_HOME
XDG_CONFIG_HOME="$DOTS_LOC/config/.config"

# if sudo is a command, then do sudo for the session
if command -v sudo &>/dev/null; then
    if [[ "$EUID" -ne 0 ]]; then
        echo "Running with sudo..."
        # use just sudo to quickly elevate privileges
        sudo -E "$0" "$@"
    fi
else
    echo "Warning: 'sudo' command not found. Running without elevated privileges."
fi

# install neovim based on the os
OS=$(uname -s)
# if linux
if [[ "$OS" == "Linux" ]]; then
    if command -v apt-get &>/dev/null; then
        apt-get update && sudo apt-get install -y neovim
    elif command -v yum &>/dev/null; then
        yum install -y neovim
    elif command -v dnf &>/dev/null; then
        dnf install -y neovim
    elif command -v pacman &>/dev/null; then
        pacman -Syu neovim
    elif command -v zypper &>/dev/null; then
        zypper install -y neovim
    elif command -v apk &>/dev/null; then
        apk add neovim
    elif command -v emerge &>/dev/null; then
        emerge --ask app-editors/neovim
    elif command -v xbps-install &>/dev/null; then
        xbps-install -S neovim
    elif command -v brew &>/dev/null; then
        brew install neovim
    elif command -v flatpak &>/dev/null; then
        flatpak install flathub org.neovim.nvim
    elif command -v snap &>/dev/null; then
        snap install nvim --classic
    else
        echo "Unsupported Linux distribution. Please install neovim manually."
        exit 1
    fi
fi

# if windows
if [[ "$OS" == "MINGW"* || "$OS" == "MSYS"* || "$OS" == "CYGWIN"* || "$OS" == "win32" ]]; then
    if command -v winget &>/dev/null; then
        winget install Neovim.Neovim
    else
        echo "Unsupported Windows package manager. Please install neovim manually."
        exit 1
    fi
fi

# start nvim with the config directory
nvim .
