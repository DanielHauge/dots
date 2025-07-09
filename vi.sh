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

# ensure git is installed otherwise install it based on the OS
if ! command -v git &>/dev/null; then
    echo "git is not installed. Installing git..."

    OS=$(uname -s)
    case "$OS" in
    Linux)
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v yum &>/dev/null; then
            sudo yum install -y git
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y git
        elif command -v pacman &>/dev/null; then
            sudo pacman -Syu git
        elif command -v zypper &>/dev/null; then
            sudo zypper install -y git
        elif command -v apk &>/dev/null; then
            sudo apk add git
        elif command -v emerge &>/dev/null; then
            sudo emerge --ask dev-vcs/git
        elif command -v xbps-install &>/dev/null; then
            sudo xbps-install -S git
        elif command -v brew &>/dev/null; then
            brew install git
        elif command -v flatpak &>/dev/null; then
            flatpak install flathub org.gnome.gitg
        elif command -v snap &>/dev/null; then
            sudo snap install git --classic
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

TEMP_LOC="$(mktemp -d "$TMPBASE/daniel-dots.XXXXXX")"
git clone --depth 1 https://github.com/DanielHauge/dots.git "$TEMP_LOC"
"$TEMP_LOC"/quick-init/vi.sh "$TEMP_LOC"
