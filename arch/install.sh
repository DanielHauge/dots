#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo -e "\033[1;34m[INFO]\033[0m $*"; }

if ! command -v zsh &>/dev/null; then
    log "Installing zsh..."
    sudo pacman -Syuu zsh --noconfirm

    chsh -s "$(command -v zsh)"

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

fi

if ! command -v cargo; then
    sudo pacman -Syuu --noconfirm --needed curl base-devel
    log "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
    export PATH="$HOME/.cargo/bin:$PATH"
    log "Installing tree-sitter..."
    zsh -c "cargo install tree-sitter-cli"
    zsh -c "cargo install --locked bacon"
fi

if ! command -v paru; then
    log "Installing paru..."
    (
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/paru.git "$tmpdir"
        cd "$tmpdir"
        makepkg -si --noconfirm
        rm -rf "$tmpdir"
    )
fi

paru -Syuu --needed --noconfirm - <~/dots/arch/packages.txt

(
    log "Stowing configuration files..."
    cd "$HOME/dots" || exit
    stow -R config
)

log "Provisioning complete."
