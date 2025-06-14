# setup hyprland & kitty conf in dots

# grub stuff

<https://github.com/vinceliuice/grub2-themes>
sudo grub-mkconfig -o /boot/grub/grub.cfg

sudo pacman -S glibc libxss libnotify nss alsa-lib freetype2 fontconfig

# Packages installed, not registered in the package manager

```bash
comm -23 <(pacman -Qentq | sort) <(sort ~/dots/arch/packages.txt)
```
