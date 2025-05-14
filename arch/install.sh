#!/bin/bash

install_zsh() {
    echo "Installing zsh..."
    sudo pacman -Syuu zsh --noconfirm
    chsh -s "$(which zsh)"

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

while read -r pack; do
    if ! pacman -Q "$pack" &>/dev/null; then
        echo "Installing $pack..."
        sudo pacman -Syuu --noconfirm "$pack"
    else
        echo "$pack is already installed."
    fi
done <packages.txt

(
    cd ~/dots || exit
    stow -R config
)

if ! command -v paru; then
    echo "Installing paru..."
    (
        cd ~ || exit
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si --noconfirm
    )
fi
