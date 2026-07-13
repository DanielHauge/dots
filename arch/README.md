# Arch setup

Install Arch interactively with the [Arch installation guide](https://wiki.archlinux.org/title/Installation_guide)
or `archinstall`, then clone this repository and run:

```bash
./arch/install.sh
```

The installer reconciles the common package lists, adds the NVIDIA profile when
that GPU is detected, enables selected services, and replaces managed dotfiles
with repository links. Intel and AMD systems use the shared desktop packages.
Preview actions first with `./arch/install.sh --dry-run`.

Use `./arch/install.sh --profile nvidia` when automatic detection should be
overridden. Driver packages are managed through pacman/paru; current NVIDIA
packages enable DRM modesetting by default. Reboot after installing the NVIDIA
profile.

Use `./arch/sync.sh` for later package maintenance. Its removal actions are
deliberately not part of `install.sh`.
