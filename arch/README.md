# Arch setup

Install Arch with `archinstall`, create a non-root desktop user with sudo, and
boot in UEFI mode. Mount the persistent FAT EFI System Partition at `/efi`.

Run as that desktop user:

```bash
curl -fsSL https://raw.githubusercontent.com/DanielHauge/dots/main/arch/init.sh | bash
```

If you are already root, name the desktop user explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/DanielHauge/dots/main/arch/init.sh | bash -s -- --user daniel
```

The bootstrap installs Git, updates `~/dots` with a fast-forward-only pull,
then runs the installer as the desktop user. AUR packages and dotfiles are
never installed as root; system changes use `sudo`.

Before provisioning an existing checkout:

```bash
~/dots/arch/install.sh --check --boot-stack refind-uki
~/dots/arch/install.sh --dry-run --boot-stack refind-uki
```

Rerun the same bootstrap command after correcting a failure. Installation only
adds missing packages by default; package removal remains opt-in through
`~/dots/arch/sync.sh -a`.
