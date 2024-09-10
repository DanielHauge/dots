#!/bin/bash

# Update package lists
sudo apt update

is_installed() {
	dpkg -l | grep -q "^ii  $1\s"
}

# Regolith Linux

if ! is_installed regolith-desktop; then
	echo "Adding Regolith Linux public key to local apt..."
	wget -qO - https://regolith-desktop.org/regolith.key |
		gpg --dearmor | sudo tee /usr/share/keyrings/regolith-archive-keyring.gpg >/dev/null

	dist=$(lsb_release -a | awk '{print $2}' | head -n3 | tail -n1)

	echo deb "[arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] \
        https://regolith-desktop.org/release-3_2-ubuntu-noble-amd64 noble main" |
		sudo tee /etc/apt/sources.list.d/regolith.list

	sudo apt update
	sudo apt install regolith-desktop regolith-session-flashback regolith-look-cahuella
	# regolith-look-lascaille
	echo "Done installing regolith-desktop. Reboot!"

fi

# Install APT packages
apt_packages=(
	git
	neovim
	zoxide
	gcc
	nmap
)
# Install each package if it's not already installed
for package in "${apt_packages[@]}"; do
	if is_installed "$package"; then
		echo "$package is already installed."
	else
		sudo apt install -y "$package"
	fi
done

# Install apt-get packages
apt_get_packages=(
)

for package in "${apt_get_packages[@]}"; do
	if is_installed "$package"; then
		echo "$package is already installed."
	else
		sudo apt install -y "$package"
	fi
done

# Install Snap packages
is_snap_installed() {
	snap list | grep -q "^$1\s"
}
snap_packages=(
	dotnet-sdk
	dotnet-runtime-80
	ripgrep
	zig
	node
	difftastic
	ruff
	ffmpeg
	vlc
	go
	openjdk
	glow
	shellcheck
	flutter
)
for snap in "${snap_packages[@]}"; do
	if is_snap_installed "$snap"; then
		echo "$snap is already installed."
	else
		sudo snap install "$snap"
	fi
done

#
# # Install Flatpak packages
# is_flatpak_installed() {
# 	flatpak list | grep -q "^$1\s"
# }
# flatpak_packages=(
# 	package1
# 	package2
# )
# for flatpak in "${flatpak_packages[@]}"; do
# 	if is_flatpak_installed "$flatpak"; then
# 		echo "$flatpak is already installed."
# 	else
# 		flatpak install -y "$flatpak"
# 	fi
# done
#

echo "All programs installed successfully!"
