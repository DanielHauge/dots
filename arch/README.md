# Arch setup

Use the official Arch ISO and guided `archinstall`. Select UEFI boot, networking,
a non-root user with sudo access, a persistent FAT ESP mounted at `/efi`, and add `curl`
to the additional packages.

In Archinstall's post-install chroot, become that user and run:

```bash
su - daniel
curl -fsSLo /tmp/dots-init https://dots.feveile-hauge.dk/arch/init.sh && bash /tmp/dots-init && rm /tmp/dots-init
```

Replace `daniel` with the user created by Archinstall. The user shell keeps a
real terminal, so the installer can prompt for sudo and build AUR packages
safely. If `curl` was missed during installation, install it as root in the
chroot first:

```bash
pacman -S --needed curl
```

Reboot into the installed system using the bootloader configured by Archinstall,
then add rEFInd and UKIs:

```bash
~/dots/arch/install.sh --boot-stack refind-uki
```

For an existing installed system:

```bash
~/dots/arch/install.sh --check --boot-stack refind-uki
~/dots/arch/install.sh --dry-run --boot-stack refind-uki
```
