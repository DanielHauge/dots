#!/bin/bash

apt_packages=(
	git
	neovim
	alacritty
	zoxide
	gcc
	tree-sitter-cli
	nmap
	neofetch
)

snap_packages=(
	dotnet-sdk
	dotnet-runtime-80
	ripgrep
	zig
	node
	ruff
	ffmpeg
	vlc
	go
	discord
	openjdk
	glow
	shellcheck
	flutter
)

sudo apt update

is_installed() {
	dpkg -l | grep -q "^ii  $1\s"
}

if ! is_installed regolith-desktop; then
	echo "Adding Regolith Linux public key to local apt..."
	wget -qO - https://regolith-desktop.org/regolith.key |
		gpg --dearmor | sudo tee /usr/share/keyrings/regolith-archive-keyring.gpg >/dev/null

	dist=$(lsb_release -a | awk '{print $2}' | head -n3 | tail -n1)

	echo deb "[arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] \
        https://regolith-desktop.org/release-3_2-ubuntu-noble-amd64 noble main" |
		sudo tee /etc/apt/sources.list.d/regolith.list

	sudo apt update
	sudo apt install regolith-desktop regolith-session-flashback regolith-look-lascaille
	# regolith-look-lascaille
	echo "Done installing regolith-desktop. Reboot!"

fi

for package in "${apt_packages[@]}"; do
	if is_installed "$package"; then
		echo "$package is already installed."
	else
		sudo apt install -y "$package"
	fi
done

is_snap_installed() {
	snap list | grep -q "^$1\s"
}
for snap in "${snap_packages[@]}"; do
	if is_snap_installed "$snap"; then
		echo "$snap is already installed."
	else
		sudo snap install "$snap" --classic
	fi
done

echo "All programs installed successfully!"
