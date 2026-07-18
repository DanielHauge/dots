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
real terminal, so the installer can prompt for sudo and build `paru` from AUR
after the initial full system upgrade. If `curl` was missed during installation,
install it as root in the chroot first:

```bash
pacman -Syu --needed curl
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

`sync.sh` installs packages listed in the manifests. To review and optionally
remove explicitly installed packages outside those manifests, run:

```bash
~/dots/arch/cleanup.sh --dry-run
~/dots/arch/cleanup.sh
```
