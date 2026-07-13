#!/usr/bin/env bash
set -euo pipefail

ESP=/efi

printf 'UEFI: '
[[ -d /sys/firmware/efi ]] && echo yes || echo no
printf 'ESP: '
findmnt -no TARGET,FSTYPE --target "$ESP" 2>/dev/null || echo "not mounted"
printf 'rEFInd entry: '
efibootmgr 2>/dev/null | grep -i refind || echo "missing"
printf 'Default UKI: '
[[ -s "$ESP/EFI/Linux/arch-linux.efi" ]] && echo present || echo missing
printf 'Fallback UKI: '
[[ -s "$ESP/EFI/Linux/arch-linux-fallback.efi" ]] && echo present || echo missing
printf 'Plymouth: '
grep -qw plymouth /etc/mkinitcpio.conf /etc/mkinitcpio.conf.d/* 2>/dev/null &&
    plymouth-set-default-theme 2>/dev/null || echo "not configured"
