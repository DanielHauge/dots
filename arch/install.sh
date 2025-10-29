#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo -e "\033[1;34m[INFO]\033[0m $*"; }

if ! command -v zsh &>/dev/null; then
    log "Installing zsh..."
    sudo pacman -Syuu zsh --noconfirm

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
    cargo install tree-sitter-cli
    cargo install --features "sound clipboard" --locked bacon
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

currently_installed=$(paru -Qq)
echo "Installing packages from packages.txt..."

while IFS= read -r line; do
    if [[ -z "$line" || "$line" =~ ^# ]]; then
        continue
    fi
    line=$(echo "$line" | xargs) # Trim whitespace

    if echo "$currently_installed" | grep -q "$line"; then
        log "Package $line is already installed, skipping."
        continue
    else
        if paru -Qs "$line" &>/dev/null; then
            log "Package $line is already installed (checked with paru -Qs), skipping."
            continue
        fi
    fi
    log "Installing package: $line"
    paru -Sy --noconfirm "$line"
done <~/dots/arch/packages.txt

(
    log "Stowing configuration files..."
    cd "$HOME/dots" || exit
    stow -R config
)

if ! command -v sddm-greeter; then
    paru -Syuu --needed --noconfirm sddm sddm-theme-deepin-git
    sudo systemctl enable sddm.service
    sudo systemctl start sddm
    sudo crudini --set /etc/sddm.conf Theme Current "deepin"
fi

log "Provisioning complete."
echo "Switch to zsh with:"
echo "chsh -s $(command -v zsh)"
