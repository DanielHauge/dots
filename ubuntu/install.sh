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

	if [ "$(lsb_release -cs)" == "jammy" ]; then
		echo "deb [signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] https://regolith-linux.org/repo jammy main" | sudo tee /etc/apt/sources.list.d/regolith.list
	else
		echo "deb [signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] https://regolith-linux.org/repo $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/regolith.list
	fi
	sudo apt update
	sudo apt install regolith-desktop regolith-session-flashback regolith-look-cahuella
	# regolith-look-lascaille
	echo "Done installing regolith-desktop. Reboot!"

fi

# Install APT packages
apt_packages=(
	package1
	package2
	package3
)
# Install each package if it's not already installed
for package in "${apt_packages[@]}"; do
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
	package1
	package2
)
for snap in "${snap_packages[@]}"; do
	if is_snap_installed "$snap"; then
		echo "$snap is already installed."
	else
		sudo snap install "$snap"
	fi
done

# Install Flatpak packages
is_flatpak_installed() {
	flatpak list | grep -q "^$1\s"
}
flatpak_packages=(
	package1
	package2
)
for flatpak in "${flatpak_packages[@]}"; do
	if is_flatpak_installed "$flatpak"; then
		echo "$flatpak is already installed."
	else
		flatpak install -y "$flatpak"
	fi
done

echo "All programs installed successfully!"
