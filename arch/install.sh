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
    kde-cli-tools # kde command line tools
    docker  
    socat # socket utility
	vlc
    tumbler # thumbnail generator for
    ffmpegthumbnailer # thumbnail generator for videos
    thunar
    gvfs
    gvfs-smb
    gnuplot
    gvfs-nfs
    avahi # lib for DLNA (Digital living network aliance) - media sharing
    libupnp # detect upnp (Universal Plug n play) devices on the network - tv for player etc.
    gupnp-tools 
    miniupnpc
    pavucontrol # audio controler for selecting audio output
    keysmith # keyring manager
    firefox
    python-pip
    python-pipx
    blueman # bluetooth manager
    mpd
    yt-dlp
    mpv
    glibc # c library
    libxss  # X11 screen saver extension library
    libnotify # notification library (inotify)
    meson
    ninja
    stylua
    nss # Network Security Services
    alsa-lib # Advanced Linux Sound Architecture
    freetype2   # font rendering library
    go  
    fontconfig # font configuration library
	tectonic 
    xorg-xrandr # X11 resize and rotate -> Just used for getting screen info
    viewnior # image viewer -> used for screenshots
    xdotool # X11 automation tool for screenshots
    maim # screenshot tool
	cargo
	flatpak
	wl-clipboard 
    glow
    shellcheck
    ruff
	org-xwayland 
	lazygit
    waybar
	exa
    wlroots # wayland compositor library
	neofetch
	stow
    ttf-fira-code
    ttf-font-awesome
    ttf-roboto
    ttf-fira-sans
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
    cargo-nextest
)

yay_packs=(
    albert
    )

# function to install packages with pacman


for pack in $packs; do
    echo "Installing $pack..."
    yes | sudo pacman -S $pack
done

for pack in $yay_packs; do
    echo "Installing $pack..."
    yay -S $pack --noconfirm
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



