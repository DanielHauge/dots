#!/bin/sh

set -eu

sudo pacman -Syu --noconfirm --needed git
(
    cd "$HOME" || exit
    if [ ! -d dots/.git ]; then
        git clone https://github.com/DanielHauge/dots.git
    fi
    "$HOME/dots/arch/install.sh" || exit
)
