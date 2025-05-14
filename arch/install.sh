#!/bin/bash

install_zsh() {
    echo "Installing zsh..."
    sudo pacman -Syuu zsh --noconfirm
    chsh -s "$(which zsh)"

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    sh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting'
    sh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions'
}

if ! command -v cargo; then
    sudo pacman -Syuu --noconfirm --needed curl base-devel
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
    echo "Installing tree-sitter..."
    sh -c "cargo install tree-sitter-cli"
fi

if ! command -v zsh; then
    install_zsh
fi

if ! command -v paru; then
    echo "Installing paru..."
    (
        cd ~ || exit
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si --noconfirm
    )
fi

paru -Syuu --needed --noconfirm - <~/dots/arch/packages.txt

(
    cd ~/dots || exit
    stow -R config
)
