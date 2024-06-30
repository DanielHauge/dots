#!/bin/bash
echo "Download tar from: https://github.com/nix-community/NixOS-WSL/releases"
# wait for enter
echo "Press enter, when download is complete"
read

# Check if file exists
if [ -f ~/Downloads/NixOS-WSL.tar.gz ]; then
	echo "Found nix tar ball"
else
	echo "Did not find nix tar ball, download may have failed"
	exit 1
fi

wsl --import NixOS "$USERPROFILE\NixOS\ " ~/Downloads/NixOS-WSL.tar.gz

wsl -s NixOS
wsl --update
