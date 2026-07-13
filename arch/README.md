# Arch setup

After installing Arch with `archinstall` in UEFI mode, mount the EFI System
Partition at `/efi`, then run:

```bash
sudo pacman -Syu --needed git && git clone https://github.com/DanielHauge/dots.git ~/dots && ~/dots/arch/install.sh --boot-stack refind-uki
```
