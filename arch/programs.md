vlc
tectonic
cargo (2:rustup)
flatpak
lazygit
exa
neofetch
stow
git
nvim
man
nodejs
discord
zsh
grub
net-tools
nfs-utils
cifs-utils
fzf

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

# setup hyprland & kitty conf in dots.


# flatpak:
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# grub stuff:
https://github.com/vinceliuice/grub2-themes
sudo grub-mkconfig -o /boot/grub/grub.cfg

sudo pacman -S glibc libxss libnotify nss alsa-lib freetype2 fontconfig

