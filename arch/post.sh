#!/bin/bash

rustup default stable
if ! command -v tree-sitter; then
    echo "Installing tree-sitter..."
    cargo install tree-sitter-cli
fi

if ! command -v paru; then
    sudo pacman -S --needed git base-devel --noconfirm
    cd ~ || exit
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si --noconfirm
fi
