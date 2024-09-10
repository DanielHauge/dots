#!/bin/bash

if not command -v locales; then
	sudo apt install locales
fi
apt_packages=(
	git
	locales
	neovim
	alacritty
	zoxide
	gcc
	tree-sitter-cli
	software-properties-common
	curl
	nmap
	xclip
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
sudo apt upgrade -y

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

if is_installed "ros-jazzy-ros-desktop"; then
	echo "ROS already installed."
else
	echo "Installing ROS..."
	sudo add-apt-repository universe
	sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list >/dev/null
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y ros-jazzy-desktop-full ros-dev-tools
fi

if ! command -v zsh; then
	echo 'deb http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-autosuggestions/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/shells:zsh-users:zsh-autosuggestions.list
	curl -fsSL https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-autosuggestions.gpg >/dev/null
	echo 'deb http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/shells:zsh-users:zsh-syntax-highlighting.list
	curl -fsSL https://download.opensuse.org/repositories/shells:zsh-users:zsh-syntax-highlighting/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-syntax-highlighting.gpg >/dev/null
	sudo apt update
	sudo apt install zsh zsh-syntax-highlighting zsh-autosuggestions
	chsh -s "$(which zsh)"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
fi

echo "All programs installed successfully!"
