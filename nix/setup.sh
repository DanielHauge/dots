#!/bin/bash

sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --update
sudo nixos-rebuild switch

git clone https://github.com/DanielHauge/dots.git
sudo sed -i "/imports = \[/a \  $(pwd)/dots/nix/packs.nix" /etc/nixos/configuration.nix
sudo nixos-rebuild switch
