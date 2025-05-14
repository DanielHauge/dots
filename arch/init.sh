#!/bin/sh

sudo pacman -Syuu --noconfirm --needed curl base-devel git
(
    cd ~ || exit
    git clone https://github.com/DanielHauge/dots.git
    ~/dots/arch/install.sh || exit
    echo "Success - To make dots pushable, run:"
    echo "dots-auth"
)
