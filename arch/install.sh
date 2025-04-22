#!/bin/bash

install_zsh() {
    echo "Installing zsh..."
    sudo pacman -S zsh
    chsh -s "$(which zsh)"

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
}

if ! command -v zsh; then
    install_zsh
fi

while read -r pack; do
    if ! command -v "$pack"; then
        echo "Installing $pack..."
        sudo pacman -S "$pack"
    fi
done <packages.txt

if ! command -v cargo; then
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup default stable
fi

if ! command -v tree-sitter; then
    echo "Installing tree-sitter..."
    cargo install tree-sitter-cli
fi
