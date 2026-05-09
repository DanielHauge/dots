#!/bin/sh

sudo pacman -Syuu --noconfirm --needed curl base-devel git paru
(
    cd "$HOME" || exit
    git clone https://github.com/DanielHauge/dots.git
    "$HOME/dots/arch/install.sh" || exit
    echo "Success - To make dots pushable, run:"
    echo "dots-auth"
)
