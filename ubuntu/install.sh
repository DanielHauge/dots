#!/bin/bash

# exit on failure
set -e

apt_packages=(
    git
    thunderbird
    bear
    clang-tools
    nload
    locales
    bat
    baobab
    htop
    python3-rocker
    ghex
    evince
    pandoc
    neovim
    python3-pip
    inkscape
    wine
    ca-certificates
    eza
    texlive-full
    whois
    fzf
    alacritty
    gimp
    zoxide
    gcc
    tree-sitter-cli
    software-properties-common
    curl
    python3.12-venv
    nmap
    xclip
    neofetch
    rustup
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
    code
    chromium
    discord
    openjdk
    glow
    shellcheck
    flutter
)

# sudo apt update
# sudo apt upgrade -y

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
    sudo apt install regolith-desktop regolith-session-flashback regolith-compositor-picom-glx
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

if is_installed "ros-jazzy-desktop"; then
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
    sudo apt update
    sudo apt install zsh -y
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    rm ~/.zshrc
    ln -sf "$DOTS_LOC"/.config/.zshrc ~/.zshrc
fi

if ! command -v docker; then
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
fi

if ! command -v tectonic; then
    curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net | sh
fi

echo "All programs installed successfully!"
