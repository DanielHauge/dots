#!/bin/zsh

echo "Installing packages..."


# install zsh
install_zsh() {
    echo "Installing zsh..."
    sudo pacman -S zsh
    chsh -s $(which zsh)

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
}

if ! command -v zsh; then
    install_zsh
fi

# make array of packages
packs=(
	vlc
    firefox
    glibc
    libxss
    libnotify
    nss
    alsa-lib
    freetype2
    go
    fontconfig
	tectonic
	cargo
	flatpak
	wl-clipboard
    glow
    shellcheck
    ruff
	org-xwayland
	lazygit
	exa
	neofetch
	stow
	git
	nvim
	man
	nodejs
    unzip
    npm
	discord
	grub
	net-tools
	nfs-utils
	cifs-utils
	fzf
	ripgrep
	bat
	fd
	exa
	zoxide
    whois
    wine
    clang
    git-lfs
    pandoc
)

# function to install packages with pacman


for pack in $packs; do
    echo "Installing $pack..."
    yes | sudo pacman -S $pack
done

if ! command -v cargo; then
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup default stable
fi

if ! command -v tree-sitter; then
    echo "Installing tree-sitter..."
    cargo install tree-sitter-cli
fi



