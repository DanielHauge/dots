#!/bin/bash

set -euo pipefail

# Determine a safe temp directory
if [[ -n "${TMPDIR:-}" ]]; then
    TMPBASE="$TMPDIR"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    TMPBASE="${TEMP:-${TMP:-/tmp}}"
else
    TMPBASE="/tmp"
fi

# check if sudo
if command -v sudo &>/dev/null; then
    sudo "$0" "$@"
    exit 0
fi

# ensure git is installed otherwise install it based on the OS
if ! command -v git &>/dev/null; then
    echo "git is not installed. Installing git..."

    OS=$(uname -s)
    case "$OS" in
    Linux)
        if command -v apt-get &>/dev/null; then
            apt-get update && apt-get install -y git
        elif command -v yum &>/dev/null; then
            yum install -y git
        elif command -v dnf &>/dev/null; then
            dnf install -y git
        elif command -v pacman &>/dev/null; then
            pacman -Syu git
        elif command -v zypper &>/dev/null; then
            zypper install -y git
        elif command -v apk &>/dev/null; then
            apk add git
        elif command -v emerge &>/dev/null; then
            emerge --ask dev-vcs/git
        elif command -v xbps-install &>/dev/null; then
            xbps-install -S git
        elif command -v brew &>/dev/null; then
            brew install git
        elif command -v flatpak &>/dev/null; then
            flatpak install flathub org.gnome.gitg
        elif command -v snap &>/dev/null; then
            snap install git --classic
        else
            echo "Unsupported Linux distribution. Please install git manually."
            exit 1
        fi
        ;;
    *)
        echo "Unsupported OS: $OS. Please install git manually."
        exit 1
        ;;
    esac
fi

TMPBASE="~/.daniels-vim-YOU-CAN-DELTE-ME"
git clone --depth 1 https://github.com/DanielHauge/dots.git "$TMPBASE/dots"
echo "Cloned dots repository to $TMPBASE"
"$TMPBASE"/dots/quick-init/vi.sh "$TMPBASE"
